
// Skill levels
#define SKILL_LEVEL_NONE 0
#define SKILL_LEVEL_NOVICE 1
#define SKILL_LEVEL_APPRENTICE 2
#define SKILL_LEVEL_JOURNEYMAN 3
#define SKILL_LEVEL_EXPERT 4
#define SKILL_LEVEL_MASTER 5
#define SKILL_LEVEL_LEGENDARY 6

//Skill experience thresholds
#define SKILL_EXP_NOVICE 100
#define SKILL_EXP_APPRENTICE 250
#define SKILL_EXP_JOURNEYMAN 500
#define SKILL_EXP_EXPERT 900
#define SKILL_EXP_MASTER 1500
#define SKILL_EXP_LEGENDARY 2500

//Skill modifier types
#define SKILL_SPEED_MODIFIER "skill_speed_modifier"


// Gets the reference for the skill type that was given
#define GetSkillRef(A) (SSskills.all_skills[A])

//number defines
#define CLEAN_SKILL_BEAUTY_ADJUSTMENT	15//It's a denominator so no 0. Higher number = less cleaning xp per cleanable
#define CLEAN_SKILL_GENERIC_WASH_XP	1.5//Value. Higher number = more XP when cleaning non-cleanables (walls/floors/lips)

#define SKATER_SKILL_GRIND_XP 1 //how much skeet you greet per grinding some iron, totals the bow wow then pounds you up or down depending on whether you landed it or slammed
