#include "test.h"
#include <iostream>
using namespace std;

//ostream& operator<<(ostream& os, const char* msg)
//{
//	os <<endl<< msg << endl;
//	return os;
//}

void logFormat(const char* msg)
{
	cout << endl << "=======" << msg << "=======" << endl;
}

//test lua_call
int luaCall(lua_State* L)
{
	logFormat("luaCall");

	lua_getfield(L, LUA_GLOBALSINDEX, "f");
	lua_pushstring(L, "c call lua");
	lua_getfield(L, LUA_GLOBALSINDEX, "t");
	lua_getfield(L, -1, "x");
	lua_remove(L, -2);
	lua_pushinteger(L, 10);
	lua_call(L, 3, 1);
	lua_setfield(L, LUA_GLOBALSINDEX, "a");
	return 0;
}

// register c into lua
int add(lua_State* L)
{
	logFormat("add");

	lua_pushinteger(L,
		luaL_checkinteger(L, 1) + luaL_checkinteger(L, 2));
	return 1;
}

//cclourse
int counter(lua_State* L)
{
	int val = lua_tointeger(L, lua_upvalueindex(1));
	lua_pushinteger(L, ++val);//++val 

	lua_pushvalue(L, -1);//++val ++val
	lua_replace(L, lua_upvalueindex(1));
	return 1;
}

int newCounter(lua_State* L)
{
	logFormat("newCounter");
	lua_pushinteger(L, 0);
	lua_pushcclosure(L, counter, 1);
	return 1;
}

////env table
//int setValue(lua_State* L)
//{
//	luaL_checkstring(L, -1);
//	lua_pushvalue(L, -1);
//	lua_setfield(L, LUA_ENVIRONINDEX, "key1");
//	return 0;
//}
//
//int getValue(lua_State* L)
//{
//	lua_getfield(L, LUA_ENVIRONINDEX, "key1");
//	return 1;
//}


//static const luaL_Reg envFunc[] = {
//	"getValue", getValue,
//	"setValue", setValue,
//	NULL, NULL
//};

//int registerEnv(lua_State*L)
//{
//	lua_newtable(L);
//	lua_replace(L, LUA_ENVIRONINDEX);
//	luaL_register(L, "envTest", envFunc);
//	lua_pop(L, 1);
//	return 1;
//}

int vec2Tbl(lua_State* L, std::vector<int>& vec)
{
	logFormat("vec2Tbl");
	lua_newtable(L);//t
	int i = 0;
	for each (int var in vec)
	{
		lua_pushnumber(L, ++i);
		lua_pushinteger(L, var);
		lua_rawset(L, -3);
		/*lua_pushinteger(L, var);
		lua_rawgeti(L, -2, ++i);*/
	}
	return 1;
}

int tbl2Vec(lua_State* L)
{
	logFormat("tbl2Vec");
	int len = lua_objlen(L, -1);
	vector<string> vec;
	for (int i = 0; i < len; ++i)
	{
		lua_rawgeti(L, -1, i + 1);
		vec.push_back(lua_tostring(L, -1));
		lua_pop(L, 1);
	}

	for (vector<string>::iterator it = vec.begin();
		it != vec.end();++it)
	{
		cout << it->c_str()<<",";
	}
	cout << endl;
	return 0;
}

static const luaL_Reg regFunc[] = {
	"add", add,
	"counter", counter,
	"newCounter", newCounter,
	"tbl2Vec", tbl2Vec,
	NULL, NULL
};

int registerIntoLua(lua_State* L)
{
	luaL_register(L, "_G", regFunc);
	lua_pop(L, 1);
	return 0;
}
