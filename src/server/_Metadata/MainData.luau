export type MainData = {
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
}

local MainData: MainData = {
	coins = 0,
	xp = 0,
	tools = {},
	petsOwned = {},
	petsEquipped = {},
	quests = {},

	facility = {},
}

return MainData
