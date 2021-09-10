{{$prefix := index (reFindAllSubmatches `Prefix of \x60\d+\x60: \x60(.+)\x60` (exec "prefix")) 0 1}}
{{$args := parseArgs 1 (print $prefix "mod <UserID/Mention>") (carg "userid" "User")}}

{{if reFind `\d+` .StrippedMsg}}
	{{$user := userArg ($args.Get 0)}}
	{{$userid := $args.Get 0}}
	{{$users := "Unknown User"}}
	{{$usera := "https://cdn.discordapp.com/emojis/565142262401728512.png"}}

	{{if (userArg (index .CmdArgs 0))}}
		{{$userid = $user.ID}}
		{{$users = $user.String}}
		{{$usera = $user.AvatarURL "1024"}}
	{{end}}

	{{$x := sendMessageRetID nil (cembed
		"author" (sdict
		"name" (print $users " - Mod Panel")
		"icon_url" $usera)
		"description" "🔨 - Ban, 👢 - Kick, 🔇 - Mute, 🔊 - Unmute, ❌ - Close Menu")}}

	{{/*Permission Check*/}}
	{{$var1 := split (index (split (exec "viewperms") "\n") 2) ", "}}

	{{/*Ban*/}}
	{{if (in $var1 "BanMembers")}}
		{{addMessageReactions nil $x "🔨"}}
	{{end}}

	{{/*Kick*/}}
	{{if (in $var1 "KickMembers")}}
		{{if $user}}
			{{addMessageReactions nil $x "👢"}}
		{{end}}
	{{end}}

	{{/*Mute*/}}
	{{if (in $var1 "ManageRoles")}}
		{{if $user}}
			{{addMessageReactions nil $x "🔇" "🔊"}}
		{{end}}
	{{end}}

	{{addMessageReactions nil $x "❌"}}
	{{$v1 := dbSetExpire .User.ID (print .CCID "-" (randInt 10000) "del_message") (print "del" $x "-" .Message.ID) 300}}
	{{$v2 := dbSetExpire .User.ID "mod_rq_message" (print "mod" $x "-" $userid) 300}}

	{{deleteMessage nil $x 300}}
	{{deleteTrigger 300}}
{{else}}This ID is invalid and doesn't exist!{{end}}
