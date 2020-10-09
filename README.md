## YaST - Sudo Configuration

The intention of this module is to provide a User Interface for configuring
`sudo`.

### Known Limitations

- It uses a handcrafter Perl parser that has some limitations, especially when
  it comes to deal with new `sudo` features or complex configuration.
  Alternatives like Augeas lenses are more up-to-date. For specific limitations
  see below.
- Support for `@include` and `@includedir` directive is limited. It just shows
  them in rules section, but nothing more. Also duplicated alias detection does
  not work across included files.
- `sudo` configuration does not support multitags in rules, which leads to
  refuse to work with error message.
- `sudo` configuration does not support command specific tags in rules, which leads to
  refuse to work with error message.
- The module does not allow to see/edit the global configuration of `sudo` (key
  `Defaults`).
- No support for commands digest feature. If found then it refuses to work.
- It can only work with `/etc/sudoers`.
