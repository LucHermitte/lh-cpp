## lh-cpp Options

### Options types

- Global options: `g:`_{option-name}_  
  They are best set from the `.vimrc`;
- Local/project-wise options: `b:`_{option-name}_  
  They are best set from a [`local_vimrc` file](https://github.com/LucHermitte/local_vimrc);
- Project-wise options with default: `(bg):`_{option-name}_  
  Their default value can be set in the `.vimrc`, but its best to set them from a
  [`local_vimrc` file](https://github.com/LucHermitte/local_vimrc);
- [lh-dev options](https://github.com/LucHermitte/lh-dev#options-1):
  `(bg):`_[{filetype}\_]{option-name}_

### Option list

#### `(bg):cpp_std_flavour` and `$CXXFLAGS`
These options are exploited by [C++ flavour decoding functions](doc/API.md#c++-flavour)

The expected values for `(bg):cpp_std_flavour` are "03", "05" (TR1), "11", "14", or "17".
Other values will lead into Unspecified Behaviour. 

**warning:** "98" is not a valid value.

If `(bg):cpp_std_flavour` is not set, the flavour will be extracted from the
`-std=` option in `$CXXFLAGS` or else from the CMake `$CMAKE_CXXFLAGS` option.
Valid values are `-std=c++98`, `-std=c++03`, `-std=c++0x`, `-std=c++11`,
`-std=c++1y`,  `-std=c++14`, `-std=c++1z`, `-std=c++17` (the `-std=gnu++xx`
ones are also handled)

**Note:** The `$CMAKE_CXXFLAGS` option is obtained thanks to
[lh-cmake](https://github.com/LucHermitte/lh-cmake).

