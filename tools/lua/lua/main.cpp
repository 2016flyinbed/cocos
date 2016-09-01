#include<iostream>
#include<lua.hpp>
#include "console.h"
#include "test.h"
using namespace std; 

int panic(lua_State* L)
{
	(void)L;//to avoid warnings
	fprintf(stderr, "PANIC:unprotected error in call to Lua API (%s)\n",
		lua_tostring(L, -1));
	return 0;
}

int main(int argc, char* argv[])
{
	lua_State* L = lua_open();
	lua_atpanic(L, &panic);
	luaL_openlibs(L);
	registerIntoLua(L);
	luaL_dofile(L, "script/main.lua");

	luaCall(L);

	lua_settop(L, 0);
	lua_getfield(L, LUA_GLOBALSINDEX, "createTable");
	vector<int> vec = { 10, 20, 9, 99, 88 };
	vec2Tbl(L, vec);
	cout << "lua_typename = " << lua_typename(L, lua_type(L, -1)) << endl;
	lua_pcall(L, 1, 1, 0);
	tbl2Vec(L);

	PressAnyKeyToContinue();
	return 0;
}
