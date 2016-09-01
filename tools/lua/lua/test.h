#pragma once

#include "lua.hpp"
#include <vector>
int registerEnv(lua_State* L);
int registerIntoLua(lua_State* L);
int luaCall(lua_State* L);


int vec2Tbl(lua_State* L, std::vector<int>& vec);
int tbl2Vec(lua_State* L);