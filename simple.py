#!/usr/bin/env python

"""
assert tests of Hkl package adapted from tests/bindings/python.py

export GI_TYPELIB_PATH=/APSshare/linux/64/lib/girepository-1.0
"""

import gi
gi.require_version("Hkl", "5.0")
from gi.repository import Hkl

v = Hkl.Vector()
assert type(v) == Hkl.Vector, "correct type"
assert type(v.data) == list, "data is a list"
assert 3 == len(v.data), "data has 3 values"

assert v.data == [0.0, 0.0, 0.0]
v.init(1, 2, 3)
assert v.data == [1.0, 2.0, 3.0]
