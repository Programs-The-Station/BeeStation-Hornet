/*
	Defines for use in saycode and text formatting.
	Currently contains speech spans and message modes
*/

#define RADIO_EXTENSION "department specific"
#define RADIO_KEY "department specific key"
#define LANGUAGE_EXTENSION "language specific"

//Message modes. Each one defines a radio channel, more or less.

//if you use ! as a mode key for some ungodly reason, change the first character for ion_num() so get_message_mode() doesn't freak out with state law prompts - shiz.
#define MODE_HEADSET "headset"
#define MODE_ROBOT "robot"

#define MODE_R_HAND "right hand"
#define MODE_KEY_R_HAND "r"

#define MODE_L_HAND "left hand"
#define MODE_KEY_L_HAND "l"

#define MODE_INTERCOM "intercom"
#define MODE_KEY_INTERCOM "i"
#define MODE_TOKEN_INTERCOM ":i"

#define MODE_BINARY "binary"
#define MODE_KEY_BINARY "b"
#define MODE_TOKEN_BINARY ":b"

#define WHISPER_MODE "the type of whisper"
#define MODE_WHISPER "whisper"
#define MODE_WHISPER_CRIT "whispercrit"

#define MODE_DEPARTMENT "department"
#define MODE_KEY_DEPARTMENT "h"
#define MODE_TOKEN_DEPARTMENT ":h"

#define MODE_ALIEN "alientalk"
#define MODE_HOLOPAD "holopad"

#define MODE_SLIMELINK "slimelink"
#define MODE_KEY_SLIMELINK "j"

#define MODE_HOLOPARASITE		"holoparasite"
#define MODE_KEY_HOLOPARASITE	"p"

#define MODE_VOCALCORDS "cords"
#define MODE_KEY_VOCALCORDS "x"

#define MODE_SING "sing"
#define MODE_CUSTOM_SAY_EMOTE "custom_say"
#define MODE_CUSTOM_SAY_ERASE_INPUT "erase_input"
#define MODE_UNTREATED_MESSAGE "untreated_message" /// This is used to store untreated message for specific cases because lizardperssson sssaysss thingsss incorrectly

//Spans. Robot speech, italics, etc. Applied in compose_message().
#define SPAN_ROBOT "robot"
#define SPAN_YELL "yell"
#define SPAN_ITALICS "italics"
#define SPAN_SANS "sans"
#define SPAN_PAPYRUS "papyrus"
#define SPAN_REALLYBIG "reallybig"
#define SPAN_COMMAND "command_headset"
#define SPAN_MEGAPHONE "megaphone"
#define SPAN_CLOWN "clowntext"
#define SPAN_SINGING "singing"
#define SPAN_TAPE_RECORDER "tape_recorder"

//bitflag #defines for return value of the radio() proc.
#define ITALICS			(1<<0)
#define REDUCE_RANGE	(1<<1)
#define NOPASS			(1<<2)

//Eavesdropping
#define EAVESDROP_EXTRA_RANGE 1 //! how much past the specified message_range does the message get starred, whispering only

/// How close intercoms can be for radio code use
#define MODE_RANGE_INTERCOM 1

// Is the message actually a radio message
#define MODE_RADIO_MESSAGE "actuallyradiomessage"

// A link given to ghost alice to follow bob
#define FOLLOW_LINK(alice, bob) "<a href='byond://?src=[REF(alice)];follow=[REF(bob)]'>(F)</a>"
#define TURF_LINK(alice, turfy) "<a href='byond://?src=[REF(alice)];x=[turfy.x];y=[turfy.y];z=[turfy.z]'>(T)</a>"
#define FOLLOW_OR_TURF_LINK(alice, bob, turfy) "<a href='byond://?src=[REF(alice)];follow=[REF(bob)];x=[turfy.x];y=[turfy.y];z=[turfy.z]'>(F)</a>"

#define LINGHIVE_NONE 0
#define LINGHIVE_OUTSIDER 1
#define LINGHIVE_LING 2
#define LINGHIVE_LINK 3

/// Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN			1024
#define MAX_NAME_LEN			42
#define MAX_BROADCAST_LEN		512
#define MAX_CHARTER_LEN			80

// Is something in the IC chat filter? This is config dependent.
#define CHAT_FILTER_CHECK(T) (CONFIG_GET(flag/ic_filter_enabled) && config.ic_filter_regex && findtext(T, config.ic_filter_regex))
// Is something in the OOC chat filter?
#define OOC_FILTER_CHECK(T) (CONFIG_GET(flag/ooc_filter_enabled) && config.ooc_filter_regex && findtext(T, config.ooc_filter_regex))

// Audio/Visual Flags. Used to determine what sense are required to notice a message.
#define MSG_VISUAL (1<<0)
#define MSG_AUDIBLE (1<<1)

//Used in visible_message_flags, audible_message_flags and message_mods
#define CHATMESSAGE_EMOTE "emotemessage"

/// By default, self_message will respect the visual / audible component of the message.
/// Meaning that if the message is visual, and sourced from a blind mob, they will not see it.
/// This flag skips that behavior, and will always show the self message to the mob.
#define ALWAYS_SHOW_SELF_MESSAGE "showselfmessage"

///How far away blind people can see visible messages from
#define BLIND_TEXT_DIST 2

// Bitflags for emotes, used in var/emote_type of the emote datum
/// Is the emote audible
#define EMOTE_AUDIBLE (1<<0)
/// Is the emote visible
#define EMOTE_VISIBLE (1<<1)
/// Is it an emote that should be shown regardless of blindness/deafness
#define EMOTE_IMPORTANT (1<<2)
/// Emote only prints to runechat, not to the chat window
#define EMOTE_RUNECHAT (1<<3)
// Animated emote bitflag
#define EMOTE_ANIMATED (1<<4)

