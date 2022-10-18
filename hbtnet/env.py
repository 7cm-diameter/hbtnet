from abc import ABCMeta, abstractmethod
from collections.abc import Iterable
from typing import List, Optional

import numpy as np
from scipy.stats import expon, geom

import hbtnet.types as tp


def _eqdiv(n: int) -> List[float]:
    return [(i + 1) / (n + 1) for i in range(n)]


class Schedule(metaclass=ABCMeta):

    @abstractmethod
    def step(self, action: tp.Action, time: tp.Time) -> tp.Reward:
        pass

    @property
    @abstractmethod
    def finished(self) -> bool:
        pass

    @abstractmethod
    def reset(self):
        pass


class FixedRatio(Schedule):

    def __init__(self, ratio: int, reward: tp.Reward, max_reward: int,
                 repeat: bool):
        self._RATIO = ratio
        self._REWARD = reward
        self._MAX_REWARD = max_reward
        self._REPEAT = repeat
        self._response_count = 0
        self._reward_count = 0

    def step(self, action: tp.Action, _time: tp.Time) -> tp.Reward:
        if self.finished:
            return 0.
        if action > 0:
            self._response_count += 1
            if self._response_count >= self._RATIO:
                self._response_count = 0
                self._reward_count += 1
                if self.finished and self._REPEAT:
                    self.reset()
                return self._REWARD
        return 0.

    @property
    def finished(self) -> bool:
        return self._reward_count >= self._MAX_REWARD

    def reset(self):
        self._reward_count = 0


class VariableRatio(Schedule):

    def __init__(self, ratio: int, reward: tp.Reward, max_reward: int,
                 repeat: bool):
        self._RATIO = ratio
        self._REWARD = reward
        self._MAX_REWARD = max_reward
        self._REPEAT = repeat
        _ratios = geom.ppf(_eqdiv(self._MAX_REWARD), p=1 / self._RATIO)
        self._ratios = np.random.choice(_ratios,
                                        size=self._MAX_REWARD,
                                        replace=False)
        self._response_count = 0
        self._reward_count = 0
        self._current_ratio = self._ratios[self._reward_count]

    def step(self, action: tp.Action, _time: tp.Time) -> tp.Reward:
        if self.finished:
            return 0.
        if action > 0:
            self._response_count += 1
            if self._response_count >= self._current_ratio:
                self._response_count = 0
                self._reward_count += 1
                if self.finished and self._REPEAT:
                    self.reset()
                elif not self.finished:
                    self._current_ratio = self._ratios[self._reward_count]
                return self._REWARD
        return 0.

    @property
    def finished(self) -> bool:
        return self._reward_count >= self._MAX_REWARD

    def reset(self):
        _ratios = geom.ppf(_eqdiv(self._MAX_REWARD), p=1 / self._RATIO)
        self._ratios = np.random.choice(_ratios,
                                        size=self._MAX_REWARD,
                                        replace=False)
        self._response_count = 0
        self._reward_count = 0
        self._current_ratio = self._ratios[self._reward_count]


class VariableInterval(Schedule):

    def __init__(self, interval: float, reward: tp.Reward, max_reward: int,
                 repeat: bool):
        self._INTERVAL = interval
        self._REWARD = reward
        self._MAX_REWARD = max_reward
        self._REPEAT = repeat
        _intervals = expon.ppf(_eqdiv(self._MAX_REWARD), scale=self._INTERVAL)
        self._intervals = np.random.choice(_intervals,
                                           size=self._MAX_REWARD,
                                           replace=False)
        self._interval_count = 0.
        self._reward_count = 0
        self._current_interval = self._intervals[self._reward_count]

    def step(self, action: tp.Action, time: tp.Time) -> tp.Reward:
        if self.finished:
            return 0.
        self._interval_count += time
        if self._interval_count >= self._current_interval and action > 0:
            self._interval_count = 0.
            self._reward_count += 1
            if self.finished and self._REPEAT:
                self.reset()
            elif not self.finished:
                self._current_interval = self._intervals[self._reward_count]
            return self._REWARD
        return 0.

    @property
    def finished(self) -> bool:
        return self._reward_count >= self._MAX_REWARD

    def reset(self):
        _intervals = expon.ppf(_eqdiv(self._MAX_REWARD), p=1 / self._INTERVAL)
        self._intervals = np.random.choice(_intervals,
                                           size=self._MAX_REWARD,
                                           replace=False)
        self._interval_count = 0.
        self._reward_count = 0
        self._current_interval = self._intervals[self._reward_count]


class VariableTime(Schedule):

    def __init__(self, interval: float, reward: tp.Reward, max_reward: int,
                 repeat: bool):
        self._INTERVAL = interval
        self._REWARD = reward
        self._MAX_REWARD = max_reward
        self._REPEAT = repeat
        _intervals = expon.ppf(_eqdiv(self._MAX_REWARD), scale=self._INTERVAL)
        self._intervals = np.random.choice(_intervals,
                                           size=self._MAX_REWARD,
                                           replace=False)
        self._interval_count = 0.
        self._reward_count = 0
        self._current_interval = self._intervals[self._reward_count]

    def step(self, action: tp.Action, time: tp.Time) -> tp.Reward:
        if self.finished:
            return 0.
        self._interval_count += time
        if self._interval_count >= self._current_interval:
            self._interval_count = 0.
            self._reward_count += 1
            if self.finished and self._REPEAT:
                self.reset()
            elif not self.finished:
                self._current_interval = self._intervals[self._reward_count]
            return self._REWARD
        return 0.

    @property
    def finished(self) -> bool:
        return self._reward_count >= self._MAX_REWARD

    def reset(self):
        _intervals = expon.ppf(_eqdiv(self._MAX_REWARD), scale=self._INTERVAL)
        self._intervals = np.random.choice(_intervals,
                                           size=self._MAX_REWARD,
                                           replace=False)
        self._interval_count = 0.
        self._reward_count = 0
        self._current_interval = self._intervals[self._reward_count]


class ConcurrentSchedule(Schedule):

    def __init__(self, main: List[Schedule], sub: List[Schedule],
                 independent: Optional[List[Schedule]]):
        self._MAIN = main
        self._SUB = sub
        self._INDEPENDENT = independent

    def step(self, actions: Iterable[tp.Action], time: tp.Time) -> tp.Reward:
        schedules = self._MAIN + self._SUB
        reward = np.sum([s.step(a, time) for s, a in zip(schedules, actions)])
        if self._INDEPENDENT is None:
            return reward
        reward += np.sum([s.step(0, time) for s in self._INDEPENDENT])
        return reward

    @property
    def finished(self) -> List[bool]:
        return [s.finished for s in self._MAIN]

    def reset(self):
        if self._INDEPENDENT is None:
            schedules = self._MAIN + self._SUB
        else:
            schedules = self._MAIN + self._SUB + self._INDEPENDENT
        [s.reset() for s in schedules]


class TandemSchedule(Schedule):

    def __init__(self, schedules: List[Schedule]):
        self._SCHEDULES = schedules
        self._OFFSET = len(self._SCHEDULES) - 1
        self._current_schedule = 0

    def step(self, action: tp.Action, time: tp.Time) -> tp.Reward:
        reward = self._SCHEDULES[self._current_schedule].step(action, time)
        if reward > 0. and self._current_schedule == self._OFFSET:
            self._current_schedule = 0
            return reward
        if reward > 0. and self._current_schedule < self._OFFSET:
            self._current_schedule += 1
        return 0.

    @property
    def finished(self) -> bool:
        return self._SCHEDULES[-1].finished

    def reset(self):
        [s.reset() for s in self._SCHEDULES]
