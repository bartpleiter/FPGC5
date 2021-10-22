from distutils.core import setup
from Cython.Build import cythonize
setup(ext_modules = cythonize(["shivyc/*.pyx", "shivyc/parser/*.pyx", "shivyc/il_cmds/*.pyx", "shivyc/tree/*.pyx", "shivyc/*.pxd"], annotate=False, language_level = "3"))
