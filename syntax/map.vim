if exists("b:current_syntax")
  finish
endif
let b:current_syntax = "map"

syn match mapKey /%/
syn match mapLockedDoor /*/
syn match mapItem /I/
syn match mapMobile /z/
syn match mapEntrance /</
syn match mapExit />/

hi def link mapItem keyword
hi def link mapKey directory
hi def link mapLockedDoor directory
hi def link mapMobile identifier
hi def link mapEntrance error
hi def link mapExit error
