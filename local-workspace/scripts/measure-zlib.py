#!/usr/bin/env python3
"""Measure the real zlib overhead for incompressible payloads of this size."""
import os
import zlib


def pad8(n):
    return n + (-n % 8)


for n in (1000, 10000, 100000, 141000, 141100, 141110, 141120, 141130, 141135):
    packed = zlib.compress(os.urandom(n), 9)
    print('n=%-7d 压缩=%-7d 差=%-4d pad8=%d' % (n, len(packed), len(packed) - n, pad8(len(packed))))
