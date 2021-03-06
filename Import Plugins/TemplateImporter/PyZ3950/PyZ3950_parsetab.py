
# PyZ3950_parsetab.py
# This file is automatically generated. Do not edit.

_lr_method = 'SLR'

_lr_signature = '\xfc\xb2\xa8\xb7\xd9\xe7\xad\xba"\xb2Ss\'\xcd\x08\x16'

_lr_action_items = {'QUOTEDVALUE':([5,26,0,19,16,],[1,1,1,1,1,]),'LOGOP':([3,25,4,14,9,6,27,23,13,20,22,1,],[-5,-9,-14,-13,16,-8,16,-7,16,-6,-4,-12,]),'SET':([0,16,5,26,],[11,11,11,11,]),'RPAREN':([27,23,3,22,1,25,13,4,20,6,14,],[28,-7,-5,-4,-12,-9,20,-14,-6,-8,-13,]),'$':([8,14,2,23,3,20,28,25,9,1,4,6,22,],[0,-13,-1,-7,-5,-6,-3,-9,-2,-12,-14,-8,-4,]),'SLASH':([21,],[26,]),'ATTRSET':([0,],[7,]),'QUAL':([0,26,16,18,5,],[10,10,10,24,10,]),'COMMA':([10,12,24,],[-10,18,-11,]),'LPAREN':([26,0,16,7,5,],[5,5,5,15,5,]),'WORD':([19,17,14,0,5,26,6,16,15,1,4,25,],[4,23,-13,4,4,4,14,4,21,-12,-14,14,]),'RELOP':([11,24,10,12,],[17,-11,-10,19,]),}

_lr_action = { }
for _k, _v in _lr_action_items.items():
   for _x,_y in zip(_v[0],_v[1]):
       _lr_action[(_x,_k)] = _y
del _lr_action_items

_lr_goto_items = {'cclfind_or_attrset':([0,],[2,]),'elements':([5,26,16,0,],[3,3,22,3,]),'quallist':([5,26,0,16,],[12,12,12,12,]),'val':([5,16,26,19,0,],[6,6,6,25,6,]),'top':([0,],[8,]),'cclfind':([5,0,26,],[13,9,27,]),}

_lr_goto = { }
for _k, _v in _lr_goto_items.items():
   for _x,_y in zip(_v[0],_v[1]):
       _lr_goto[(_x,_k)] = _y
del _lr_goto_items
_lr_productions = [
  ("S'",1,None,None,None),
  ('top',1,'p_top','./ccl.py',154),
  ('cclfind_or_attrset',1,'p_cclfind_or_attrset_1','./ccl.py',158),
  ('cclfind_or_attrset',6,'p_cclfind_or_attrset_2','./ccl.py',162),
  ('cclfind',3,'p_ccl_find_1','./ccl.py',166),
  ('cclfind',1,'p_ccl_find_2','./ccl.py',170),
  ('elements',3,'p_elements_1','./ccl.py',174),
  ('elements',3,'p_elements_2','./ccl.py',196),
  ('elements',1,'p_elements_3','./ccl.py',202),
  ('elements',3,'p_elements_4','./ccl.py',206),
  ('quallist',1,'p_quallist_1','./ccl.py',213),
  ('quallist',3,'p_quallist_2','./ccl.py',217),
  ('val',1,'p_val_1','./ccl.py',221),
  ('val',2,'p_val_2','./ccl.py',225),
  ('val',1,'p_val_3','./ccl.py',229),
]
