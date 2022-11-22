import jester
import json
import strutils
import std/json
import std/jsonutils
import times

import router_utils
import ".."/[types, api]
from ../types import User, Error

proc toJsonHook*(time: DateTime): JsonNode = 
  let errBody: string = $(%* {"error": "User not found"})
  %*($time)

proc toErrorBody*(msg: string): string = $(%* {"error": msg})

proc scopedToJson*(user: User): string = $toJson(user)

proc scopedToJson*(tweets: seq[Tweet]): string = $toJson(tweets)

export api

proc createApiRouter*(cfg: Config) =
  router api:
    get "/api/user/@name":
      if @"name".len > 15:
        resp Http400, {"Content-Type": "application/json"}, "Handle too long."

      let
        prefs = cookiePrefs()
        user = await getUser(@"name")
        
      if user.id == "":
        resp Http404, {"Content-Type": "application/json"}, toErrorBody("Invalid handle")

      resp Http200, {"Content-Type": "application/json"}, scopedToJson(user)

    get "/api/timeline/@id":
      if @"id".len > 20:
        resp Http400, {"Content-Type": "application/json"}, toErrorBody("Id too long")

      let
        prefs = cookiePrefs()
        timeline = await getTimeline(@"id")

      if timeline.content.len == 0:
        resp Http404, {"Content-Type": "application/json"}, ""
        
      resp Http200, {"Content-Type": "application/json"}, scopedToJson(timeline.content)
      