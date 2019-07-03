#!/usr/bin/env bash

#set -x 

PATH_MATCH_TYPE=0 # 0:接受所有路径，排除规则中的路径
                  # 1:拒绝所有路径，匹配规则中的路径
                  # 2:接受所有路径，根据规则中关键词排除路径

FILE_MATCH_TYPE=1 # 0:选取所有文件，跳过规则中的文件
                  # 1:忽略所有文件，命中规则中的文件

ANDROID_PATH_RULE=(./ocr_ui ./.git)

JAVA_WEB_PATH_RULE=(./build ./.git) 

OTHER_PATH_RULE=(./build ./.git)

PATH_RULE=$JAVA_WEB_PATH_RULE #数组形式

FILE_RULE="^[a-zA-Z_0-9].*(java|gradle|properties|xml|lst)$"

function check_path()
{
  local is_ok=1
  if [ $# -eq 1 ]; then
    local value=$1
    if [ -e "$value" ]; then      
       case "$PATH_MATCH_TYPE" in
         "0")
           is_ok=0
           for ((i=0;i<${#PATH_RULE[@]};i++)); do
               local item=${PATH_RULE[i]}
               if [ "$value" == $item ]; then
                  is_ok=1
                  break
               fi
           done 
         ;;
         "1")
           is_ok=1
           for ((i=0;i<${#PATH_RULE[@]};i++)); do
               local item=${PATH_RULE[i]}
               if [ "$value" == $item ]; then
                  is_ok=0
                  break
               fi
           done 
         ;;
         "2")
           is_ok=0
           echo "${PATH_RULE[*]}" | grep -qE "$value"
           if [ $? -eq 0 ]; then
              is_ok=1
           fi 
         ;;
         *)
           echo "unknown path match type:$PATH_MATCH_TYPE"
           exit 1
         ;;
         esac
    fi
  fi
  return "$is_ok"
}

function check_file()
{
  local is_ok=1
  if [ $# -eq 1 ]; then
    local value=$1
    case "$FILE_MATCH_TYPE" in
      "0")
        is_ok=0
        echo "$value" | grep -qE "$FILE_RULE"
        if [ $? -eq 0 ]; then
           is_ok=1
        fi       
      ;;
      "1")
        #set -x
        is_ok=1
        echo "$value" | grep -qE "$FILE_RULE"
        if [ $? -eq 0 ]; then
           is_ok=0
        fi
        #set +x     
      ;;
      *)
        echo "unknown file match type:$FILE_MATCH_TYPE"
        exit 1
      ;;
    esac
  fi 
  return "$is_ok"
}

###================================================================================

COUNT=1

OFFSET=0

EXPECT_COUNT=20

IS_ALL=false # true|false 是否处理全部匹配文件，注意开启时expect、count失效，offset始终生效

IS_ENABLE_ROOT_STRING=false # true|false 是否启用根字符

ROOT_STRING=""

PROJECT_TREE_ROOT="."

OUTPUT="./out.xml"

function app()
{
  if [ $1 -eq 0 ]; then
     echo "Usage:$(basename $0) -arsofep <path>"
     exit 0
  fi
  shift 1
  while getopts ":s:o:f:e:p:ra" opt; do
    case "$opt" in
       "a") IS_ALL=true ;;
       "r") IS_ENABLE_ROOT_STRING=true ;;
       "s") ROOT_STRING="$OPTARG" ;;
       "o") OUTPUT="$OPTARG" ;;
       "f") OFFSET="$OPTARG" ;;
       "e") EXPECT_COUNT="$OPTARG" ;;
       "p") PROJECT_TREE_ROOT="$OPTARG" ;;
       "?") echo "Invalid option: -$OPTARG"; exit 1 ;;
    esac
  done
  unset opt
  shift $((OPTIND-1))
#  echo "r:$IS_ENABLE_ROOT_STRING"
#  echo "s:$ROOT_STRING"
#  echo "o:$OUTPUT"
#  echo "off:$OFFSET"
#  echo "exp:$EXPECT_COUNT"
#  echo "pro:$PROJECT_TREE_ROOT"
#  printf "\n"
  local oth="$@"
  if [ "$oth" != "" ]; then
    rm -rf "$OUTPUT" #清空可能存在的输出文件
    make_xml "$PROJECT_TREE_ROOT" "$OUTPUT" $oth
    show_details
  fi
}

function make_xml()
{
  if [ $# -ge 3 ]; then
    local project_root=$1
    local output=$2
    shift 2
    declare -a path_list=("$@")
    local tmp=$(mktemp -u)
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$tmp"
    #echo "<?xml version=\"1.0\" encoding=\"ISO-8859\"?>" > "$tmp"
    echo "<codeDoc>" >> "$tmp"
    create_project_tree "$project_root" "$tmp"
    for ((i=0;i<${#path_list[@]};i++)); do
       local item=${path_list[i]}
       match_file_to_output "$item" "$tmp" "$OFFSET"
    done
    unset i
    echo "</codeDoc>" >> "$tmp"
    if [ -e "$tmp" ]; then
       mv "$tmp" "$output"
    fi
  fi
}

function show_details()
{  
  if [ -e "$OUTPUT" ]; then
     local count=$((COUNT-1))
     local line=0
     local size=0
     line=$(wc -l "$OUTPUT" | awk '{printf $1}')
     size=$(du -h "$OUTPUT" | awk '{printf $1}')
     echo -e "\n$OUTPUT"
     echo "Success! count:$count offset:$OFFSET expect:$EXPECT_COUNT line:$line size:$size" 
  fi
}

function create_project_tree()
{
   local path=$1
   local output=$2
   local tmp=$(mktemp -u)
   tree -n -o "$tmp" "$path"
   sed -i '$d' "$tmp"
   sed -i '$d' "$tmp" 
   echo "<part>" >> "$output"
   echo "<header font-name=\"宋体\" font-size=\"10.5\" bold=\"yes\">程序源代码目录树结构图</header>" >> "$output"
   echo "<content font-name=\"宋体\" font-size=\"10.5\">" >> "$output"
   cat "$tmp" >> "$output"
   echo "</content>" >> "$output"
   echo "</part>" >> "$output"
   rm -rf "$tmp"
}

function root_string()
{
 # set -x
  local res="$*"
  if [ $# -eq 1 ] && $IS_ENABLE_ROOT_STRING; then
    res=($(echo "$1" | awk -F "/" -v rstr="$ROOT_STRING" '{$1=rstr; print $0}'))
    res=$(echo ${res[*]} | sed 's/ /\\/g')
  fi
  echo "$res"
 # set +x
}

function match_file_to_output()
{
  #set -x
  if [ $# -eq 3 ]; then
     local path=$1
     local output=$2
     local offset=$3
     check_path "$path"
     if [ $? -eq 0 ]; then
        printf "\e[5;36m===> path:%s\e[m\n" "$path"
        for file in $(ls -A "$path"); do
	  if [ $COUNT -gt $EXPECT_COUNT ] && ! $IS_ALL; then break; fi
	  local pf="$path/$file"
	  if [ -d "$pf" ]; then
             match_file_to_output "$pf" "$output" "$offset" #递归处理
	  elif [ -f "$pf" ]; then
	     #set -x
	     check_file "$file"
	     if [ $? -eq 0 ]; then
                #set -x
                if [ $offset -gt 0 ]; then
                   printf "\e[5;33moffset:%s\e[m\n" "$file"
                   ((offset--))
                   continue
                fi
                #set +x
                local name=$(root_string "$pf")
		printf "\e[5;32m%s ~> %s\e[m\n" "$pf" "$name"
                #生成part
		echo "<part>" >> "$output"
                #echo "$COUNT. $pf" >> "$output"
                echo "<header font-name=\"宋体\" font-size=\"10.5\" bold=\"yes\">$COUNT. $name</header>" >> "$output"
                echo "<content font-name=\"宋体\" font-size=\"10.5\">" >> "$output"
		#sed "/^$/d" "$pf" >> "$output"
		
		#echo "<![CDATA[" >> "$output"
		#cat "$pf" >> "$output"
                #echo "]]>" >> "$output"

                #用实体替换特殊字符
		sed -e "s/&/\&amp;/g"  \
                    -e "s/</\&lt;/g"   \
		    -e "s/>/\&gt;/g"   \
		    -e "s/'/\&apos;/g" \
		    -e "s/\"/\&quot;/g" "$pf" >> "$output"

		#echo "" >> "$output"
		echo "</content>" >> "$output"
		echo "</part>" >> "$output"

		((COUNT++))
             else
                printf "\e[5;40mignore:%s\e[m\n" "$file"
	     fi
	     #read -p "next?" opt
	     #set +x
	  fi
	done
	unset file
     else
	printf "\e[5;31mskip:%s\e[m\n" "$path"
     fi
  fi
}

app "$#" "$@"
