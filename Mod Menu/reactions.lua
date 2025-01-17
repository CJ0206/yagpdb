{{$grab := ""}}
{{$call := dbGetPattern .User.ID "%message" 100 0}}

{{range $call}}
	{{if eq .UserID .User.ID}}
		{{$grab = print $grab " " .Value}}
	{{end}}
{{end}}

{{/*Delete Embed*/}}
{{$t11 := `del(?:(?P<MessageIDEmbed>\d{18})-(?P<MessageIDAuthor>\d{18}))`}}

{{range $call}}
	{{if and (eq $.Reaction.Emoji.Name "❌") (reFind $t11 .Value)}}
		{{$m := reFindAllSubmatches $t11 .Value}}
		{{if (reFind (str $.Reaction.MessageID) (str .Value))}}
			{{deleteMessage $.Reaction.ChannelID (index (index $m 0) 1) 0}}
			{{deleteMessage $.Reaction.ChannelID (index (index $m 0) 2) 0}}
			{{dbDelByID .UserID .ID}}
		{{end}}
	{{end}}
{{end}}

{{$e1 := `mod(?:(?P<MessageID>\d{18})-(?P<ModUserID>\d{18}))`}}

{{if and $call (reFind $e1 $grab)}}	{{$matches := reFindAllSubmatches $e1 $grab}}	{{$user := userArg (index (index $matches 0) 2)}}
	{{$users := "Unknown User"}}
	{{$usera := "https://cdn.discordapp.com/emojis/565142262401728512.png"}}
	{{$userid := toInt (index (index $matches 0) 2)}}
	{{if $user}}
		{{$users = $user.String}}
		{{$usera = $user.AvatarURL "1024"}}
	{{end}}
	{{/*Ban User*/}}
	{{if eq .Reaction.Emoji.Name "🔨"}}
		{{range $call}}
			{{$grab = (print $grab " " .Value)}}
		{{end}}
		{{if (reFind `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{$matches := (reFindAllSubmatches `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{if eq (str .Reaction.MessageID) (str (index (index $matches 0) 1))}}
				{{editMessage nil .Reaction.MessageID (cembed
				"author" (sdict
					"name" (print $users " - Mod Panel")
					"icon_url" $usera)
				"description" "Option to ban 🔨 this user:\n🍏 - 1 Day\n🍎 - 1 Week\n🍊 - 2 Months\n🍋 - 4 Months\n🍌 - Permanent"
				"color" 0x77FF68)}}
				{{deleteAllMessageReactions nil .Reaction.MessageID}}
				{{addMessageReactions nil .Reaction.MessageID "🍏" "🍎" "🍊" "🍋" "🍌" "❌"}}
				{{dbSetExpire .User.ID "modmenu" "ban" 300}}
			{{end}}
		{{end}}
	{{end}}

	{{/*Kick User*/}}
	{{if eq .Reaction.Emoji.Name "👢"}}
		{{range $call}}
			{{if eq .UserID $.User.ID}}
				{{$grab = (print $grab " " .Value)}}
			{{end}}
		{{end}}
		{{if (reFind `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{$matches := (reFindAllSubmatches `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{if eq (str .Reaction.MessageID) (str (index (index $matches 0) 1))}}
				{{deleteAllMessageReactions nil (str .Reaction.MessageID)}}
				{{addMessageReactions nil (str .Reaction.MessageID) "❌"}}
				{{editMessage nil (str .Reaction.MessageID) (cembed
				"author" (sdict
					"name" (print $users " - Mod Panel")
					"icon_url" $usera)
				"description" (exec "kick" $userid "Kicked by Mod Panel")
				"color" 0x77FF68)}}
			{{end}}
		{{end}}
	{{end}}

	{{/*Mute User*/}}
	{{if eq .Reaction.Emoji.Name "🔇"}}
		{{range $call}}
			{{$grab = (print $grab " " .Value)}}
		{{end}}
		{{if (reFind `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{$matches := (reFindAllSubmatches `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{if eq (str .Reaction.MessageID) (str (index (index $matches 0) 1))}}
				{{editMessage nil (str .Reaction.MessageID) (cembed
				"author" (sdict
					"name" (print $users " - Mod Panel") 
					"icon_url" $usera)
				"description" "Option to mute 🔇 this user:\n🍏 - 5 Minutes\n🍎 - 10 Minutes\n🍊 - 20 Minutes\n🍋 - 1 Hour"
				"color" 0x77FF68)}}
				{{deleteAllMessageReactions nil (str .Reaction.MessageID)}}
				{{addMessageReactions nil (str .Reaction.MessageID) "🍏" "🍎" "🍊" "🍋" "❌"}}
				{{dbSetExpire .User.ID "modmenu" "mute" 300}}
			{{end}}
		{{end}}
	{{end}}

	{{/*Unmute User*/}}
	{{if eq .Reaction.Emoji.Name "🔊"}}
		{{range $call}}
			{{if eq .UserID .User.ID}}
				{{$grab = (print $grab " " .Value)}}
			{{end}}
		{{end}}
		{{if (reFind `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{$matches := (reFindAllSubmatches `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{if eq (str .Reaction.MessageID) (str (index (index $matches 0) 1))}}
				{{deleteAllMessageReactions nil (str .Reaction.MessageID)}}
				{{addMessageReactions nil (str .Reaction.MessageID) "❌"}}
				{{editMessage nil (str .Reaction.MessageID) (cembed
				"author" (sdict
					"name" (print $users " - Mod Panel")
					"icon_url" $usera)
				"description" (exec "unmute" $userid "Unmuted by Mod Panel")
				"color" 0x77FF68)}}
			{{end}}
		{{end}}
	{{end}}

	{{/*Checking for time emojis*/}}
	{{$result := 0}}{{$mute := "0"}}{{$ban := "0"}}
	{{if eq .Reaction.Emoji.Name "🍏"}}
		{{$result = 1}}{{$mute = "5m"}}{{$ban = "-d 1d"}}
	{{end}}
	{{if eq .Reaction.Emoji.Name "🍎"}}
		{{$result = 1}}{{$mute = "10m"}}{{$ban = "-d 1w"}}
	{{end}}
	{{if eq .Reaction.Emoji.Name "🍊"}}
		{{$result = 1}}{{$mute = "20m"}}{{$ban = "-d 2mo"}}
	{{end}}
	{{if eq .Reaction.Emoji.Name "🍋"}}
		{{$result = 1}}{{$mute = "1h"}}{{$ban = "-d 4mo"}}
	{{end}}
	{{if eq .Reaction.Emoji.Name "🍌"}}
		{{$result = 1}}{{$ban = "-d p"}}
	{{end}}

	{{if eq $result 1}}
		{{range $call}}
			{{if eq .UserID .User.ID}}
				{{$grab = (print $grab " " .Value)}}
			{{end}}
		{{end}}

	{{if (reFind `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{$matches := (reFindAllSubmatches `mod(?:(?P<MessageID>\d+)-(?P<ModUserID>\d+))` $grab)}}
			{{$author := (sdict "name" (print $users " - Mod Panel") "icon_url" $usera)}}

			{{if eq (str .Reaction.MessageID) (str (index (index $matches 0) 1))}}
				{{if eq (str (dbGet .User.ID "modmenu").Value) "mute"}}
					{{deleteAllMessageReactions nil (str .Reaction.MessageID)}}
					{{addMessageReactions nil (str .Reaction.MessageID) "❌"}}
					{{editMessage nil (str .Reaction.MessageID) (cembed
					"author" $author
					"description" (exec "mute" $userid $mute "Muted by Mod Panel")
					"color" 0x77FF68)}}
				{{end}}

				{{if eq (str (dbGet .User.ID "modmenu").Value) "ban"}}
					{{deleteAllMessageReactions nil (str .Reaction.MessageID)}}
					{{addMessageReactions nil (str .Reaction.MessageID) "❌"}}
					{{editMessage nil (str .Reaction.MessageID) (cembed
						"author" $author
						"description" (exec "ban" $userid $ban "Banned by Mod Panel")
						"color" 0x77FF68)}}
				{{end}}

			{{end}}
		{{end}}
	{{end}}
{{end}}
