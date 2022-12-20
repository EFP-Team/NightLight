#define LAZY_TEMPLATE_KEY_NUKIEBASE "LT_NUKIEBASE"
#define LAZY_TEMPLATE_KEY_WIZARDDEN "LT_WIZARDDEN"
#define LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY "LT_NINJAHOLDING"
#define LAZY_TEMPLATE_KEY_ABDUCTOR_SHIPS "LT_ABDUCTORSHIPS"

#define LAZY_TEMPLATE_KEY_LIST_ALL(...) list( \
	"Nukie Base" = LAZY_TEMPLATE_KEY_NUKIEBASE, \
	"Wizard Den" = LAZY_TEMPLATE_KEY_WIZARDDEN, \
	"Ninja Holding" = LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY, \
	"Abductor Ships" = LAZY_TEMPLATE_KEY_ABDUCTOR_SHIPS, \
)

GLOBAL_LIST_INIT(lazy_templates, generate_lazy_template_map())
