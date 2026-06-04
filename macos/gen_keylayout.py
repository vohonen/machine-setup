#!/usr/bin/env python3
# Generates a macOS .keylayout reproducing the customized Finnish (kotoistus) TeX layout
# from vohonen/ubuntu-setup's `fi` file. Literal characters only; rare level-3/4 dead-key
# diacritics are omitted (add later if needed). Two ISO keys (50 and 10) must be verified
# on-device; if swapped, exchange their entries.

# keycode: (base, shift, option, option+shift)  -- None omits that level
M = {
 # number row
 50: ('@','\u00C5','\u00E5',None),       # TLDE  -> @ Å å      (VERIFY ISO vs 10; plain @ because AeroSpace alt-2 shadows opt+2)
 18: ('1','!',None,'\u00A1'),
 19: ('2','"','@','\u201D'),
 20: ('3','#','\u00A3','\u00BB'),
 21: ('4','\u00A4','$','\u00AB'),
 23: ('5','%','\u20AC','\u201E'),
 22: ('6','&','\u201A','\u201E'),
 26: ('7','/','{',None),
 28: ('8','(','[','<'),
 25: ('9',')',']','>'),
 29: ('0','=','}','\u00B0'),
 27: ('+','?','\\','\u00BF'),             # AE11 -> + ? \ ¿
 24: ('{','}','`',None),                  # AE12 -> { } `
 # top letter row
 12: ('q','Q',None,None),
 13: ('w','W',None,None),
 14: ('e','E','\u20AC',None),
 15: ('r','R',None,None),
 17: ('t','T','\u00FE','\u00DE'),
 16: ('y','Y',None,None),
 32: ('u','U',None,None),
 34: ('i','I','\u0131','|'),              # optshift -> |
 31: ('o','O','\u0153','\u0152'),
 35: ('p','P',None,None),
 33: ('$','<','>',None),                  # AD11 -> $ < >
 30: ('\\','^','~',None),                 # AD12 -> \ ^ ~
 # home row
 0:  ('a','A','\u0259','\u018F'),
 1:  ('s','S','\u00DF','\u1E9E'),
 2:  ('d','D','\u00F0','\u00D0'),
 3:  ('f','F',None,None),
 5:  ('g','G',None,None),
 4:  ('h','H',None,None),
 38: ('j','J',None,None),
 40: ('k','K','\u0138',None),
 37: ('l','L',None,None),
 41: ('\u00F6','\u00D6','\u00F8','\u00D8'),   # AC10 -> ö Ö ø Ø
 39: ('\u00E4','\u00C4','\u00E6','\u00C6'),   # AC11 -> ä Ä æ Æ
 42: ("'",'*','|',None),                  # BKSL -> ' * |
 # bottom row
 10: ('<','>','|',None),                  # LSGT -> < > |       (VERIFY ISO vs 50)
 6:  ('z','Z','\u0292','\u01B7'),
 7:  ('x','X','\u00D7','\u00B7'),
 8:  ('c','C',None,None),
 9:  ('v','V',None,None),
 11: ('b','B',None,None),
 45: ('n','N','\u014B','\u014A'),
 46: ('m','M','\u00B5','\u2014'),
 43: (',',';','\u2019','\u2018'),
 47: ('.',':',None,None),
 44: ('-','_','\u2013',None),
}

# control / whitespace / keypad keys -- identical in every keyMap
CTRL = {
 36:'\u000D', 48:'\u0009', 49:' ', 76:'\u000D', 117:'\u007F',
 65:'.', 67:'*', 69:'+', 75:'/', 78:'-', 81:'=',
 82:'0',83:'1',84:'2',85:'3',86:'4',87:'5',88:'6',89:'7',91:'8',92:'9',
}

def ent(ch):
    return "&#x%04X;" % ord(ch)

def keymap(index):
    lines = ['  <keyMap index="%d">' % index]
    for code in sorted(set(list(M) + list(CTRL))):
        out = None
        if code in M and M[code][index] is not None:
            out = M[code][index]
        elif code in CTRL:
            out = CTRL[code]
        if out is not None:
            lines.append('    <key code="%d" output="%s"/>' % (code, ent(out)))
    lines.append('  </keyMap>')
    return "\n".join(lines)

xml = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE keyboard SYSTEM "file://localhost/System/Library/DTDs/KeyboardLayout.dtd">
<keyboard group="126" id="-9001" name="Finnish TeX" maxout="1">
 <layouts>
  <layout first="0" last="255" modifiers="commonModifiers" mapSet="theMap"/>
 </layouts>
 <modifierMap id="commonModifiers" defaultIndex="0">
  <keyMapSelect mapIndex="0"><modifier keys=""/></keyMapSelect>
  <keyMapSelect mapIndex="0"><modifier keys="command"/></keyMapSelect>
  <keyMapSelect mapIndex="0"><modifier keys="caps"/></keyMapSelect>
  <keyMapSelect mapIndex="1"><modifier keys="anyShift"/></keyMapSelect>
  <keyMapSelect mapIndex="1"><modifier keys="anyShift command"/></keyMapSelect>
  <keyMapSelect mapIndex="2"><modifier keys="anyOption"/></keyMapSelect>
  <keyMapSelect mapIndex="2"><modifier keys="anyOption command"/></keyMapSelect>
  <keyMapSelect mapIndex="3"><modifier keys="anyShift anyOption"/></keyMapSelect>
 </modifierMap>
 <keyMapSet id="theMap">
%s
 </keyMapSet>
</keyboard>
''' % "\n".join(keymap(i) for i in range(4))

import os
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Finnish-TeX.keylayout')
with open(out, 'w', encoding='utf-8') as f:
    f.write(xml)
print("written", len(xml), "bytes ->", out)
