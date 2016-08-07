--The name of the mod displayed in the 'mods' screen.
name = "MagicBean"

--A description of the mod.
description = "Adds seven magic beans!Each bean can give your character temporary buffs, if you eat 3 of the same beans, you get a permanent buff. \n增加七颗魔豆，每颗都有不同的效果"

author = "victor"

version = "0.08"

api_version = 10
priority = -77

-- Compatible with both the base game, reign of giants, and dst
dont_starve_compatible = false
reign_of_giants_compatible = true
shipwrecked_compatible = false
dst_compatible = true

forumthread = ""

--These let clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = true
clients_only_mod = false

--This lets people search for servers with this mod by these tags
server_filter_tags = {"sevenbean"}

-- ModConfiguration option
configuration_options = {
    {
        name = "BOSS_DROP",
        label = "Boss drop beans\nBoss掉落豆子倍数",
        options =
        {
            {description = "1(default)", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
        },
        default = 1,
    },
    {
        name = "RED_ATK",
        label = "Red,ATK increase to\n运动豆增加攻击倍数",
        options =
        {
            {description = "Twice", data = 2},
            {description = "Three Times", data = 3},
            {description = "Four Times", data = 4},
        },
        default = 2,
    },
    {
        name = "RED_DOR",
        label = "Red,Doration of buff\n运动豆临时效果持续时间",
        options =
        {
            {description = "2 days", data = 2},
            {description = "3 days", data = 3},
            {description = "5 days", data = 4},
            {description = "10 days", data = 10},
            {description = "20 days", data = 20},
        },
        default = 3,
    },
    {
        name = "ORANGE_DEF_TEMP",
        label = "Orange,Temp DEF\n欢乐豆临时增加防御",
        options =
        {
            {description = "50%", data = 0.5},
            {description = "60%", data = 0.6},
            {description = "70%", data = 0.7},
            {description = "80%", data = 0.8},
            {description = "90%", data = 0.9},
        },
        default = 0.8,
    },
    {
        name = "ORANGE_DOR",
        label = "Orange,Doration of buff\n欢乐豆临时效果持续时间",
        options =
        {
            {description = "2 days", data = 2},
            {description = "3 days", data = 3},
            {description = "5 days", data = 4},
            {description = "10 days", data = 10},
            {description = "20 days", data = 20},
        },
        default = 5,
    },
    {
        name = "ORANGE_DEF_PERM",
        label = "Orange,Perm DEF\n欢乐豆永久增加防御",
        options =
        {
            {description = "20%", data = 0.2},
            {description = "30%", data = 0.3},
            {description = "40%", data = 0.4},
            {description = "50%", data = 0.5},
            {description = "60%", data = 0.6},
        },
        default = 0.6,
    },
    {
        name = "YELLOW_RADIUS",
        label = "Yellow,Radius of light\n光之豆发光范围",
        options =
        {
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "5", data = 4},
            {description = "10", data = 10},
            {description = "20", data = 20},
        },
        default = 10,
    },
    {
        name = "YELLOW_DOR",
        label = "Yellow,Doration of buff\n光之豆临时效果持续时间",
        options =
        {
            {description = "2 days", data = 2},
            {description = "3 days", data = 3},
            {description = "5 days", data = 4},
            {description = "10 days", data = 10},
            {description = "20 days", data = 20},
        },
        default = 10,
    },
    {
        name = "GREEN_SAN_MAX",
        label = "Green,Sanity Max add\n智慧豆精神上限提升",
        options =
        {
            {description = "50", data = 50},
            {description = "80", data = 80},
            {description = "100", data = 100},
        },
        default = 50,
    },
    {
        name = "GREEN_DOR",
        label = "Green,Doration of buff\n智慧豆临时效果持续时间",
        options =
        {
            {description = "2 days", data = 2},
            {description = "3 days", data = 3},
            {description = "5 days", data = 4},
            {description = "10 days", data = 10},
            {description = "20 days", data = 20},
        },
        default = 10,
    },
    {
        name = "BLUE_FOOD_MAX",
        label = "Blue,Hunger Max add\n美食豆饥饿上限提升",
        options =
        {
            {description = "50", data = 50},
            {description = "80", data = 80},
            {description = "100", data = 100},
        },
        default = 50,
    },
    {
        name = "BLUE_DOR",
        label = "Blue,Doration of buff\n美食豆临时效果持续时间",
        options =
        {
            {description = "2 days", data = 2},
            {description = "3 days", data = 3},
            {description = "5 days", data = 4},
            {description = "10 days", data = 10},
            {description = "20 days", data = 20},
        },
        default = 10,
    },
    {
        name = "PINK_HEALTH_MAX",
        label = "Pink,Health Max add\n爱之豆血量上限提升",
        options =
        {
            {description = "50", data = 50},
            {description = "80", data = 80},
            {description = "100", data = 100},
        },
        default = 50,
    },
    {
        name = "PINK_DOR",
        label = "Pink,Doration of buff\n爱之豆临时效果持续时间",
        options =
        {
            {description = "2 days", data = 2},
            {description = "3 days", data = 3},
            {description = "5 days", data = 4},
            {description = "10 days", data = 10},
            {description = "20 days", data = 20},
        },
        default = 10,
    },
}
