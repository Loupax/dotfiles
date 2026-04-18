static const Block blocks[] = {
	/* icon   command                                         interval  signal */
	{"",  "$HOME/src/someblocks/scripts/sb-recorder",              1,        0},
	{"",  "$HOME/src/someblocks/scripts/sb-media",                 0,        3},
	{"",  "$HOME/src/someblocks/scripts/sb-volume",                0,        2},
	{"",  "$HOME/src/someblocks/scripts/sb-network",               2,        0},
	{"",  "$HOME/src/someblocks/scripts/sb-cpu",                   2,        0},
	{"",  "$HOME/src/someblocks/scripts/sb-memory",                2,        0},
	{"",  "$HOME/src/someblocks/scripts/sb-battery",               30,       0},
	{"",  "$HOME/src/someblocks/scripts/sb-lang",                  0,        1},
	{"",  "date '+%I:%M %p - %a, %d %b %Y'",               30,       0},
};

static char delim[64] = "  |  ";
static unsigned int delimLen = 63;
