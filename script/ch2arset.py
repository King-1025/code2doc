#!/usr/bin/env python
# -*- utf-8; -*-

import os
import sys
import chardet

def check_charset(fp,mif=0.0):
    if not os.path.exists(fp):
       raise Exception("invaild file path:"+str(fp))
   
    charset_list=[]
    
    if sys.platform == "linux":
       charset_list=["utf-8","gbk","ascii"]
    elif sys.platform == "win32":
       charset_list=["gbk","utf-8","ascii"]
    else:
       charset_list=["ascii","utf-8","gbk"]
    
    ff,cc=test_charset(charset_list,fp)
    if ff == True:
       return ff,cc
    else:
       charset_list=[]

    size = min(32, os.path.getsize(fp))
    with open(fp,"rb") as f:
      res = chardet.detect(f.read(size))
      if res != None:
        enc=res["encoding"]
        cof=res["confidence"]
        if enc != None and cof >= mif:
          charset_list=[enc]
    return test_charset(charset_list,fp)

def test_charset(charset_list,file_path):
    #print(charset_list)
    for charset in charset_list:
      try:
        #print(charset)
        with open(file_path,"r",encoding=charset) as x:
             for l in x.readlines():
                pass
             return True,charset
      except Exception as e:
             #print(e)
             print("skip charset:"+charset)
    return False,None

if __name__ == "__main__":
   argc=len(sys.argv)
   if argc > 1:
     path=sys.argv[1]
     print(check_charset(path))
