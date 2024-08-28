export type Main = {
	coins: number,
	xp: number,
	tools: { string },
	petsOwned: {
		{
			id: number,
			rarity: number,
			strength: number,
			health: number,
			food: number,
			cleanliness: number,
			illness: number,
		}
	},
	petsEquipped: { number },
	quests: { { questType: string, amount: number, tracked: boolean } },

	facility: {
		typeof: number,
		upgrades: { number },
		petsIncubating: { { id: number, rarity: number, progress: number } },
		staff: { { name: string, level: number } },
		resources: {
			food: number,
			water: number,
			medicine: number,
		},
		mainColor: Color3,
		secondaryColor: Color3,
	},

	settings: {
		sfxEnabled: boolean,
		musicEnabled: boolean,

		sfxVolume: number,
		musicVolume: number,
	},

	initialized: boolean,
}

local TemplateData: Main = {
	coins = 0,
	xp = 0,
	tools = {},
	petsOwned = {},
	petsEquipped = {},
	quests = {},

	facility = {},
	settings = {
		sfxEnabled = true,
		musicEnabled = true,

		sfxVolume = 0.5,
		musicVolume = 0.45,
	},
	initialized = false,
}

return TemplateData
