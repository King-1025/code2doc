#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import argparse

import genxml as xmltool
import xml2docx as doctool 

#xmltoo.app(path="./",config=None,output="out.xml"):
#doctool.app(input_xml,output_docx="out.docx"):
__VERSION__="v1.0"

if __name__ == "__main__":
    argc = len(sys.argv)
    current,_=os.path.split(sys.argv[0])
    #print(current)
    #sys.exit(0)
    if argc > 1:
      opt=sys.argv[1]
      if opt == "init":
        if sys.platform == "linux":
          os.system(current+"/linux_init.sh")
        elif sys.platform == "win32":
          os.system(current+"\windows_init.cmd")
        else:
          raise Exception("暂不支持该类系统:"+sys.platform)
        sys.exit(0)
      if opt == "bye":
        status=os.path.join(current,"status")
        if os.path.exists(status):
          #with open(status,"r") as st: 
          os.remove(status)
          print("bye!")
        sys.exit(0)

    parser = argparse.ArgumentParser(prog="code",add_help=True,description="代码整理工具 - "+__VERSION__)
    parser.add_argument("-c",help="指定配置文件",nargs="?")
    parser.add_argument("-p",help="工程预设类型",choices=["android","java","javaweb","python","default"],nargs="?")
    parser.add_argument("-m",help="最大文件个数，默认：18",type=int,default=18,nargs="?")
    parser.add_argument("-o",help="输出路径，默认：output",default="output",nargs="?")
    parser.add_argument("-f",help="输出文件名称，默认：code.docx",default="code.docx",nargs="?")
    #parser.add_argument("-r",help="执行外部程序",choices=["init","bye"],nargs="?")
    
#    group = parser.add_mutually_exclusive_group()
#    group.add_argument("-d",help="详细模式",action="store_true")
#    group.add_argument("-s",help="安静模式",action="store_true")
    
    parser.add_argument("project_path",help="工程路径")
    args = parser.parse_args()
    
    if not os.path.exists(args.o):
        os.makedirs(args.o)

    outxml=os.path.join(args.o,"out.xml")
    outdoc=os.path.join(args.o,args.f)
    if args.c != None:
       xmltool.app(args.project_path,args.c,outxml)
    else:
       config=None
       if args.p == "android":
          config=os.path.join(current,"..","config","android.json")
       elif args.p == "java":
          config=os.path.join(current,"..","config","java.json")
       elif args.p == "javaweb":
          config=os.path.join(current,"..","config","javaweb.json")
       elif args.p == "python":
          config=os.path.join(current,"..","config","python.json")
       elif  args.p == "default":
          config=os.path.join(current,"..","config","default.json")
       xmltool.app(args.project_path,config,outxml,args.m)
   
    if os.path.exists(outxml): 
       doctool.app(outxml,outdoc)
       os.remove(outxml)
    else:
       raise Exception("Not Found XML file! path:"+outxml)
