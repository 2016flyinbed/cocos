# coding:utf-8

'''
xls文件导出工具

将会把指定的excel目录下的所有xls文件转成需要的文件(这里直接转成了代码文件方便使用)

对xls文件的要求:
  第一行:无用 备注等
  第二行:类型 int float string struct
  第三行:中文说明, 不会涉及
  第四行:英文名, 转出的字串
  之后的行都是数据

数据类型的支持:int float string struct
struct直接对应为python的默认数据结构
例如:[1,2,3,4] {1:1, 2:2, 3:3}.... 注意字符串需要引号

'''


import sys, os, traceback
import  json
import  xdrlib ,sys
import xlrd

EXCEL_PATH = "./"
OUTPUT_PYTHON_PATH = "./"
OUTPUT_JS_PATH = "./"
OUTPUT_AS_PATH = "./"
OUTPUT_LUA_PATH = "../data(test_Lua)/"

# 开关
IS_OUTPUT_PYTHON = False
IS_OUTPUT_JS = False
IS_OUTPUT_AS = False
IS_OUTPUT_LUA = True


# 数据类型
T_INT       = 0
T_FLOAT     = 1
T_STRING    = 2
T_STRUCT    = 3    # 结构体,



def _cell_to_string(cell):
    if type(cell.value) == type(u''):    # unicode
        return str(cell.value.encode('utf-8'))
    else:
        if type(cell.value) == type(0.0):   # float转string
            if int(cell.value) == cell.value:   # 如果不带小数
                #print "[warning] float->string", cell.value, '->', int(cell.value)
                return str(int(cell.value))
        return str(cell.value)


def _get_attr_type(cell):
    type_str = _cell_to_string(cell).lower()
    if type_str == 'int':         return T_INT
    elif type_str == 'float':     return T_FLOAT
    elif type_str == 'string':    return T_STRING
    elif type_str == 'struct':    return T_STRUCT


def _get_attr_name(cell):
    return _cell_to_string(cell)


def _get_attr_data(cell, attr_type, attr_name, row, col):
    res = None

    try:

        # 特殊处理 字符串返回"",其他返回None
        if cell.value == "":
            if attr_type == T_STRING:
                return ""
            else:
                return None

        if attr_type == T_INT:
            res = int(cell.value)
        elif attr_type == T_FLOAT:
            res = float(cell.value)
        elif attr_type == T_STRING:
            res = _cell_to_string(cell)
        elif attr_type == T_STRUCT:
            res = eval(_cell_to_string(cell))
    except:
        traceback.print_stack()
        print "cell ERROR row:%d col:%d value:%s attr_type:%d attr_name:%s" % \
            (row, col, repr(cell.value), attr_type, attr_name)
    return res


def export(excel_file, output_python_file, output_js_file, output_as_file, output_lua_file):
    print "exporting %s" % excel_file
    
    bk = xlrd.open_workbook(excel_file)
    sh = bk.sheets()[0]
    lines = []

    print ">>info: ", sh.nrows, "x", sh.ncols

    # 读取表头
    head_data = []
    for c in xrange(0, sh.ncols):
        # 如果属性的cell为空,则说明到附加部分,不读取
        attr_type_str = _cell_to_string(sh.col(c)[1])
        if attr_type_str:
                attr_type = _get_attr_type(sh.col(c)[1])
                attr_name = _get_attr_name(sh.col(c)[3])
                head_data.append((attr_type, attr_name))

    # 读取数据
    excel_data = {}
    for r in xrange(4, sh.nrows):
        row_data = {}
        key = None
        for c in xrange(0, len(head_data)):
            cell = sh.row(r)[c]
            (attr_type, attr_name) = head_data[c]
            attr_data = _get_attr_data(cell, attr_type, attr_name, r, c)

            if attr_data is None:
                continue

            row_data[attr_name] = attr_data
            # 用第一个数据做这行的Key
            if c == 0: key = attr_data

        excel_data[key] = row_data

    # 输出python
    if IS_OUTPUT_PYTHON:
        output_python(head_data, excel_data, output_python_file)

    # 输出JS
    if IS_OUTPUT_JS:
        output_js(head_data, excel_data, output_js_file)

    # 输出AS
    if IS_OUTPUT_AS:
        output_as(head_data, excel_data, output_as_file)

    # output LUA
    if IS_OUTPUT_LUA:
        output_lua(head_data, excel_data, output_lua_file)


PYTHON_HEAD = '# coding:utf-8\n'
def output_python(head_data, excel_data, outfile):
    #print "output_python", outfile
    f = open(outfile, 'w')
    if not f:
        print "无法创建文件:%s" % outfile
        return

    f.write(PYTHON_HEAD)
    f.write('# head: ' + ' | '.join( [d[1] for d in head_data] ) + '\n')
    f.write('data = ' + repr(excel_data) + '\n')
    f.close()


def output_js(head_data, excel_data, outfile):
    #print "output_js", outfile
    f = open(outfile, 'w')
    if not f:
        print "无法创建文件:%s" % outfile
        return

    f.write('// head: ' + ' | '.join( [d[1] for d in head_data] ) + '\n')
    file_name = os.path.split(outfile)[-1]
    var_name = file_name.split('.')[0]
    f.write(var_name + ' = ' + json.dumps(excel_data) + '\n')
    f.close()

AS_PACKAGE = 'TB'
def output_as(head_data, excel_data, outfile):
    #print "output_as", outfile
    f = open(outfile, 'w')
    if not f:
        print "无法创建文件:%s" % outfile
        return

    f.write('// head: ' + ' | '.join( [d[1] for d in head_data] ) + '\n')
    f.write('package '+ AS_PACKAGE + '{\n')
    file_name = os.path.split(outfile)[-1]
    class_name = file_name.split('.')[0]
    f.write('public class '+ class_name + '{\n')
    f.write('public static var data = ' + json.dumps(excel_data) + '\n')
    f.write('}\n')
    f.write('}\n')
    f.close()


def output_lua(head_data, excel_data, outfile):
    #print "output_lua", outfile
    f = open(outfile, 'w')
    if not f:
        print "无法创建文件:%s" % outfile
        return

    f.write('-- head: ' + ' | '.join( [d[1] for d in head_data] ) + '\n')
    file_name = os.path.split(outfile)[-1]
    var_name = file_name.split('.')[0]
    f.write(var_name + ' = {}\n')
    f.writelines(_data_tolua(var_name, excel_data))
    f.close()

def _data_tolua(var_name, excel_data):
    lines = []
    for id, record in excel_data.iteritems():
        lines.append(_record_tolua(var_name, id, record))
    return lines

def _record_tolua(var_name, id, record):
    id_name = str(id)
    if type(id) == type(''): id_name = "'"+id+"'"   # id is string

    res = var_name + '[' + id_name + ']=' + _tolua(record) + '\n'
    return res
    

def _tolua(data):
    res = ""
    if type(data) == type({}):  # dict
        res += '{'
        for k, v in data.iteritems():

            if type(k) is type(''):
                if k.isdigit():
                    res += '[\'' + str(k) + '\']=' + _tolua(v) + ','   # if k is a string of Number
                else:
                    res += str(k) + '=' + _tolua(v) + ','   # k must be string
            else:
                 res += str(k) + '=' + _tolua(v) + ','
        res += '}'
        return res

    elif type(data) == type(()) or type(data) == type([]):   # list or tuple
        res += '{'
        i = 1
        for v in data:
            res += '['+str(i)+']='+_tolua(v) + ','
            i += 1
        res += '}'
        return res

    elif type(data) == type(""):
        return "'" + data + "'"

    else:
        return str(data)




    
def main():
    # 取得文件列表
    infiles = []
    paths = os.listdir(EXCEL_PATH)
    for p in paths:
        if os.path.isfile(os.path.join(EXCEL_PATH, p)) and (p.endswith('.xls') or p.endswith('.xlsx')) and p.startswith('TB_'):
            infiles.append(p)
            print p

    # 输出
    for p in infiles:
        mod_name = p.split('.')[0] # 去掉后缀
        mod_name = mod_name[0 : (len(mod_name) - len(mod_name.split('_')[-1]) - 1)] # 去掉最后一个'_'后面的内容

        python_path = mod_name + '.py'
        js_path = mod_name + '.js'
        as_path = mod_name + '.as'
        lua_path = mod_name + '.lua'
        export(os.path.join(EXCEL_PATH, p), 
            os.path.join(OUTPUT_PYTHON_PATH, python_path), 
            os.path.join(OUTPUT_JS_PATH, js_path), 
            os.path.join(OUTPUT_AS_PATH, as_path), 
            os.path.join(OUTPUT_LUA_PATH, lua_path))


if __name__ == "__main__":
    main()
