#!/usr/bin/env python

import os
import sys


def exists_in_path_uptree(dir: str, fname: str) -> bool:
    if os.path.exists(os.path.join(dir, fname)):
        return True
    else:
        (root, topdir) = os.path.split(dir)
        return exists_in_path_uptree(root, fname) if topdir != '' else False

try:
    exists = exists_in_path_uptree(os.getcwd(), sys.argv[1])
except e:
    sys.exit(-1)
sys.exit(0 if exists else 1)
