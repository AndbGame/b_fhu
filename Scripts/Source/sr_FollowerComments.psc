;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname sr_FollowerComments Extends Quest Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE WICommentScript
Quest __temp = self as Quest
WICommentScript kmyQuest = __temp as WICommentScript
;END AUTOCAST
;BEGIN CODE
kmyQuest.Commented()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
