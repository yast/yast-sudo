## YaST - Sudo Configuration

Intention of this module is to provide UI for configuring sudo.

### Known Issues

- Module using for parsing sudoers own handcrafted perl parser which has
  limitations especially regarding new sudo changes as opposite to e.g.
  augeas lenses that are more up-to data.
- Support for `@include` and `@includedir` directive is limited. It just
  shows them in rules section, but nothing more. Also duplicite alias detection
  does not work across include files.
- Sudo configuration does not support multitag in rule, which leads to dropping
  it ( caused by limitation of parser, see above )
- Module does not allow to see/edit global configuration of sudo ( key
  `Defaults` )
- No support for commands digest feature
- Does not support `Cmd_Alias` alias for `Cmnd_Alias` and skips it
- Can work only with /etc/sudoers
