#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import os.path
import json
import re
import sys

BRANCH = '├─'
LAST_BRANCH = '└─'
TAB = '│  '
EMPTY_TAB = '   '

def get_dir_list(path, placeholder=''):
    folder_list = [folder for folder in os.listdir(path) if os.path.isdir(os.path.join(path, folder))]
    file_list = [file for file in os.listdir(path) if os.path.isfile(os.path.join(path, file))]
    result = ''
    for folder in folder_list[:-1]:
        result += placeholder + BRANCH + folder + '\n'
        result += get_dir_list(os.path.join(path, folder), placeholder + TAB)
    if folder_list:
        result += placeholder + (BRANCH if file_list else LAST_BRANCH) + folder_list[-1] + '\n'
        result += get_dir_list(os.path.join(path, folder_list[-1]), placeholder + (TAB if file_list else EMPTY_TAB))
    for file in file_list[:-1]:
        result += placeholder + BRANCH + file + '\n'
    if file_list:
        result += placeholder + LAST_BRANCH + file_list[-1] + '\n'
    return result

def create_project_tree(path):
    return get_dir_list(os.path.dirname(path))

def check_rule(o,f,r,s,t):
    flag=o
    if f == 0:
        pass
    elif f == 1:
        flag=False 
        for rf in r:
          if t == "file":
             if s == rf:
              flag=True 
              break 
          elif t == "dir":
             if rf in s:
              flag=True 
              break
          else:
              raise Exception("Invalid type:"+str(t))
    elif f == 2:
        flag=True 
        for rf in r:
          if t == "file":
            if s == rf:
              flag=False 
              break 
          elif t == "dir":
            if rf in s:
              flag=False
              break
          else:
              raise Exception("Invalid type:"+str(t))
    return flag 

def match_file_to_output(path,rule=None):
    file_list=[]
    max_count=10
    rule_dir_flag,rule_dir = 0,[]
    rule_file_flag,rule_file = 0,[]
    if rule != None:
      with open(rule,"r") as load_f:
        config = json.load(load_f)
        max_count=config["max"]
        cdir=config["dir"]
        cfile=config["file"]
        rule_dir_flag,rule_dir = cdir["flag"],cdir["rule"]
        rule_file_flag,rule_file = cfile["flag"],cfile["rule"]
        #print(rule_dir_flag,rule_dir)
        #print(rule_file_flag,rule_file)
        #return
    count=0
    for root,dirs,files in os.walk(path):
      for file in files:
        fp=os.path.join(root,file)
        suffix=os.path.splitext(fp)[1]
        is_add=check_rule(True,rule_dir_flag,rule_dir,fp,"dir")
        if is_add == True:
           is_add=check_rule(True,rule_file_flag,rule_file,suffix,"file")
           if is_add == True:
             file_list.append(fp)
             count+=1
             if count >= max_count:
               return file_list,len(file_list)
    return file_list,len(file_list)

def app(path="./",config=None,output="out.xml"):
    with open(output,"w") as f:
      f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
      f.write("<codeDoc>\n")
      f.write("<part>\n")
      f.write("<header font-name=\"宋体\" font-size=\"10.5\" bold=\"yes\">程序源代码目录树结构图</header>\n")
      f.write("<content font-name=\"宋体\" font-size=\"10.5\">\n")
      f.write(create_project_tree(path))
      f.write("</content>\n")
      f.write("</part>\n")
      file_list,size=match_file_to_output(path,config)
      for t in range(0,size):
        target=str(file_list[t])
        f.write("<part>\n")
        f.write("<header font-name=\"宋体\" font-size=\"10.5\" bold=\"yes\">"+str(t+1)+". "+target+"</header>\n")
        f.write("<content font-name=\"宋体\" font-size=\"10.5\">\n")
        print(target)
        with open(target,"r") as tf:
           for ss in tf.readlines():
              if ss == "\n":
                 continue
              tt=re.sub("&","&amp;",ss)
              tt=re.sub("<","&lt;",tt)
              tt=re.sub(">","&gt;",tt)
              tt=re.sub("'","&apos;",tt)
              tt=re.sub('"',"&quot;",tt)
              print("ss:"+ss+"tt:"+tt)
              f.write(tt)
        f.write("</content>\n")
        f.write("</part>\n")
      f.write("</codeDoc>\n")

def test():
    #print(os.path.dirname(os.getcwd()))
    #print(get_dir_list(os.path.dirname(os.getcwd())))
    app(path="../",config="/home/test0/ftp/config.json")
    #print(match_file_to_output("..","/home/test0/ftp/config.json"))

if __name__ == "__main__":
   argc=len(sys.argv)
   if argc == 3:
      app(str(sys.argv[1]),str(sys.argv[2]))
   elif argc == 4:
      app(str(sys.argv[1]),str(sys.argv[2]),str(sys.argv[3]))
   else:
     print("Usage:%s <project_path> <config_file> [output_file]" % str(sys.argv[0]))
