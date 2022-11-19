# SPDX-License-Identifier: AGPL-3.0-only
import strutils, strformat, uri

import jester

import router_utils
import ../experimental/parser/utils
import ".."/[types, api, formatters]
from ../types import User, Error

export api

proc createApiRouter*(cfg: Config) =
  router api:
    get "/api/user/@name":
      if @"name".len > 15:
        resp Http400, {"Content-Type": "application/json"}, "Handle too long."

      let
        prefs = cookiePrefs()
        json = await getRawUser(@"name")

      if json.startsWith("{\"errors"):
        resp Http404, {"Content-Type": "application/json"}, json

      resp Http200, {"Content-Type": "application/json"}, json

    get "/api/timeline/@id":
      if @"id".len > 10:
        resp Http400, {"Content-Type": "application/json"}, "Id too long"

      let
        prefs = cookiePrefs()
        json = await getRawTimeline(@"id")

      if json.startsWith("{\"errors"):
        resp Http404, {"Content-Type": "application/json"}, json
        
      resp Http200, {"Content-Type": "application/json"}, json
