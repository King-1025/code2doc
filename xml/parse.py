# -*- coding: UTF-8; -*-

from xml.dom.minidom import parse

def from_xml_to_create_docx(input_xml,output_docx="out.docx"):
   with open(input_xml,"r") as fxml:
      tree = parse(fxml)
      root = tree.documentElement
      part_list = root.getElementsByTagName("part")
      for part in part_list:
        ignore=part.getAttribute("ignore")
        if ignore != "yes":
          header=part.getElementsByTagName("header")[0]
          content=part.getElementsByTagName("content")[0]
          print("Header: %s" % header.childNodes[0].data)
          print("Content: %s" % content.childNodes[0].data)

from_xml_to_create_docx("sample_code.xml")
