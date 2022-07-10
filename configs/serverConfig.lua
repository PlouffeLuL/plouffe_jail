Auth = exports.plouffe_lib:Get("Auth")
Utils = exports.plouffe_lib:Get("Utils")
Callback = exports.plouffe_lib:Get("Callback")

Server = {
	requestDelay = 1 * 60 * 2,
	JailedPlayers = {},
	playerJobs = {}
}

Jail = {}
JailFnc = {} 

Jail.Entry = {coords = vector3(1760.0721435547, 2486.6396484375, 45.817672729492), heading = 298.3705749511719}
Jail.Out = {coords = vector3(1836.0637207031, 2594.3608398438, 46.014347076416), heading = 268.6520690917969}
Jail.Player = {}

Jail.PoliceJobs = {
	"police"
}

Jail.Utils = {
	ped = 0,
	pedCoords = vector3(0,0,0),
	inJail = false,
	jobCoolDown = false,
	jobCoolDownTime = 1000 * 60,
	softCoolDown = false,
	currentWork = nil,
	iAmStupid = false
}

Jail.BuyablesItem = {
	phone = {
		price = 10,
		label = "Telephone"
	},
	lockpick = {
		price = 35,
		label = "Lockpick"
	},
	WEAPON_SWITCHBLADE = {
		price = 60,
		label = "Switch blade"
	},
	WEAPON_POOLCUE = {
		price = 45,
		label = "Pool cue"
	}
}

Jail.Coords = {
	sendToJail = {
		jobs = {"police"},
		name = "sendToJail",
		coords = vector3(1840.6409912109, 2579.2858886719, 46.014362335205),
		maxDst = 1.5,
		protectEvents = true,
		isPed = true,
		isKey = true,
		isZone = true,
		nuiLabel = "Prison",
		aditionalParams = {type = "menu", menu = "entry"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "on_jail_event",
			key = "E"
		},
		pedInfo = {
			coords = vector3(1840.5687255859, 2577.6694335938, 46.014362335205),
			heading = 1.6036080121994,
			model = 's_m_m_prisguard_01', 
			scenario = 'WORLD_HUMAN_COP_IDLES',
			pedId = 0,
		}
	},

	sendToJail_mrpd = {
		jobs = {"police"},
		name = "sendToJail_mrpd",
		coords = vector3(473.42486572266, -1007.5437011719, 26.273466110229),
		maxDst = 1.0,
		protectEvents = true,
		isPed = true,
		isKey = true,
		isZone = true,
		nuiLabel = "Prison",
		aditionalParams = {type = "menu", menu = "entry_pd"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "on_jail_event",
			key = "E"
		},
		pedInfo = {
			coords = vector3(473.69610595703, -1005.7973022461, 26.273466110229),
			heading = 180.43209838867188,
			model = 's_m_m_prisguard_01', 
			scenario = 'WORLD_HUMAN_COP_IDLES',
			pedId = 0,
		}
	},

	sendToJail_paleto = {
		jobs = {"police"},
		name = "sendToJail_paleto",
		coords = vector3(-440.41656494141, 6010.7192382813, 27.581504821777),
		maxDst = 1.0,
		protectEvents = true,
		isKey = true,
		isZone = true,
		nuiLabel = "Prison",
		aditionalParams = {type = "menu", menu = "entry_pd"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "on_jail_event",
			key = "L"
		}
	},

	sendToJail_davis = {
		jobs = {"police"},
		name = "sendToJail_davis",
		coords = vector3(376.45321655273, -1605.2866210938, 30.051332473755),
		maxDst = 2.0,
		protectEvents = true,
		isKey = true,
		isZone = true,
		nuiLabel = "Prison",
		aditionalParams = {type = "menu", menu = "entry_pd"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "on_jail_event",
			key = "L"
		}
	},

	jailRelease = {
		name = "jailRelease",
		coords = vector3(1827.9693603516, 2579.8237304688, 46.014301300049),
		maxDst = 1.0,
		protectEvents = true,
		isPed = true,
		isKey = true,
		isZone = true,
		nuiLabel = "Parler avec le garde",
		aditionalParams = {type = "menu", menu = "guard"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "on_jail_event",
			key = "E"
		},
		pedInfo = {
			coords = vector3(1827.9693603516, 2579.8237304688, 46.014301300049),
			heading = 0.16944895684719,
			model = 's_m_m_prisguard_01', 
			scenario = 'WORLD_HUMAN_COP_IDLES',
			pedId = 0,
		}
	},

	prisonZone = {
		name = "prisonZone",
		coords = vector3(1683.5089111328, 2564.6064453125, 45.564872741699),
		maxDst = 160.0,
		protectEvents = true,
		isZone = true,
		zoneMap = {
			shouldTriggerEvent = true,
			outEvent = "plouffe_jail:outOfPrison",
		}
	},

	jail_ask_for_job = {
		name = "jail_ask_for_job",
		coords = vector3(1791.0677490234, 2556.0756835938, 45.672996520996),
		maxDst = 1.0,
		protectEvents = true,
		isPed = true,
		isKey = true,
		isZone = true,
		nuiLabel = "Demander du travail",
		aditionalParams = {type = "menu", menu = "work"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "on_jail_event",
			key = "E"
		},
		pedInfo = {
			coords = vector3(1791.0677490234, 2556.0756835938, 45.672996520996),
			heading = 88.62166595458984,
			model = 's_m_m_prisguard_01', 
			scenario = 'WORLD_HUMAN_COP_IDLES',
			pedId = 0,
		}
	},

	jail_buy_illegal_stuff = {
		name = "jail_buy_illegal_stuff",
		coords = vector3(1751.7360839844, 2535.4787597656, 43.58544921875),
		maxDst = 2.0,
		protectEvents = true,
		isPed = true,
		isKey = true,
		isZone = true,
		nuiLabel = "Voir les echanges possible",
		aditionalParams = {type = "action", fnc = "ExchangeMenu"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "on_jail_event",
			key = "E"
		},
		pedInfo = {
			coords = vector3(1751.7360839844, 2535.4787597656, 43.58544921875),
			heading = 26.23263359069824,
			model = 's_m_y_prismuscl_01', 
			scenario = 'WORLD_HUMAN_COP_IDLES',
			pedId = 0,
		}
	},

	prisonZoneBig = {
		name = "prisonZoneBig",
		coords = vector3(1683.5089111328, 2564.6064453125, 45.564872741699),
		maxDst = 300.0,
		protectEvents = true,
		isZone = true,
		zoneMap = {
			shouldTriggerEvent = true,
			inEvent = "plouffe_jail:inPrisonZoneBig",
			outEvent = "plouffe_jail:outPrisonZoneBig",
		}
	},

	prison_stupid_1 = {
		name = "prison_stupid_1",
		coords = vector3(1831.9923095703, 2585.3068847656, 53.502941131592),
		maxZ = 4.0,
		isZone = true,
		type = "box",
		box = {
			A = vector2(1845.7979736328, 2567.8068847656),
			B = vector2(1817.3229980469, 2568.0778808594),
			C = vector2(1818.5625, 2599.8198242188),
			D = vector2(1846.0499267578, 2599.9506835938)
		},
		zoneMap = {
			outEvent = "plouffe_jail:leftStupidSpot",
		 	inEvent = "plouffe_jail:enteredStupidSpot",
		 	shouldTriggerEvent = true
		}
	}
}

Jail.Menu = {
	entry = {
		{
			id = 1,
			header = "Envoyer en prison",
			txt = "Envoyer quelqu'un en prison",
			params = {
				args = {
					fnc = "JailClosestPlayer"
				}
			}
		},
		{
			id = 2,
			header = "Sortir de prison",
			txt = "Sortir quelqu'un de prison",
			params = {
				args = {
					fnc = "UnJailPlayer"
				}
			}
		}
	},

	guard = {
		{
			id = 1,
			header = "Verifier votre temps",
			txt = "Voir combien de temps il vous reste",
			params = {
				args = {
					fnc = "GetReleaseTime"
				}
			}
		}
	},

	entry_pd = {
		{
			id = 1,
			header = "Envoyer en prison",
			txt = "Envoyer quelqu'un en prison",
			params = {
				args = {
					fnc = "JailClosestPlayer"
				}
			}
		}
	},

	work = {
		{
			id = 1,
			header = "Demander du travail",
			txt = "Avoir une nouvelle tâche afin de reduire votre temps",
			params = {
				args = {
					fnc = "GetNewJob"
				}
			}
		}
	}
}

Jail.Work = {
	clean_glass = {
		label = "Nettoyer les vitres de la prison",
		coolDown = 1 * 60 * 10,
		command = "e clean2",
		timeToWork = {min = 1000 * 30, max = 1000 * 60},
		timeReduction = {min = 1, max = 3},
		zones = {
			jail_work_clean_glass_1 = {
				name = "jail_work_clean_glass_1",
				coords = vector3(1771.1712646484, 2565.9812011719, 45.586566925049),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_1", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_2 = {
				name = "jail_work_clean_glass_2",
				coords = vector3(1761.4769287109, 2568.986328125, 45.565093994141),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_2", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_3 = {
				name = "jail_work_clean_glass_3",
				coords = vector3(1716.4619140625, 2569.1071777344, 45.56489944458),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_3", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_4 = {
				name = "jail_work_clean_glass_4",
				coords = vector3(1665.1164550781, 2569.1215820312, 45.564884185791),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_4", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_5 = {
				name = "jail_work_clean_glass_5",
				coords = vector3(1792.3651123047, 2547.9216308594, 45.565097808838),
				maxDst = 0.7,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_5", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_6 = {
				name = "jail_work_clean_glass_6",
				coords = vector3(1792.4301757812, 2556.2360839844, 45.565093994141),
				maxDst = 0.7,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_6", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_7 = {
				name = "jail_work_clean_glass_7",
				coords = vector3(1792.6055908203, 2578.4067382812, 45.565086364746),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_7", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_8 = {
				name = "jail_work_clean_glass_8",
				coords = vector3(1793.0196533203, 2587.7067871094, 45.565090179443),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_8", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_9 = {
				name = "jail_work_clean_glass_9",
				coords = vector3(1791.5531005859, 2592.4072265625, 45.796012878418),
				maxDst = 0.5,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_9", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_glass_10 = {
				name = "jail_work_clean_glass_10",
				coords = vector3(1791.6898193359, 2595.1896972656, 45.796020507812),
				maxDst = 0.5,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Nettoyer la vitre",
				aditionalParams = {type = "action", jobIndex = "clean_glass", zoneIndex = "jail_work_clean_glass_10", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			}
		}
	},

	repair_electricity = {
		label = "Reparer les circuit électrique de la prison",
		coolDown = 1 * 60 * 10,
		command = "e weld",
		timeToWork = {min = 1000 * 30, max = 1000 * 60},
		timeReduction = {min = 1, max = 3},
		zones = {
			repair_electricity_1 = {
				name = "repair_electricity_1",
				coords = vector3(1760.6419677734, 2519.1494140625, 45.565086364746),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_1", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_2 = {
				name = "repair_electricity_2",
				coords = vector3(1737.4404296875, 2504.6823730469, 45.565086364746),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_2", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_3 = {
				name = "repair_electricity_3",
				coords = vector3(1706.8850097656, 2481.072265625, 45.564922332764),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_3", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_4 = {
				name = "repair_electricity_4",
				coords = vector3(1700.2322998047, 2474.8959960938, 45.564979553223),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_4", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_5 = {
				name = "repair_electricity_5",
				coords = vector3(1679.7576904297, 2480.1789550781, 45.564968109131),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_5", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_6 = {
				name = "repair_electricity_6",
				coords = vector3(1644.0231933594, 2490.8410644531, 45.564903259277),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_6", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_7 = {
				name = "repair_electricity_7",
				coords = vector3(1622.4432373047, 2507.6843261719, 45.564907073975),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_7", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_8 = {
				name = "repair_electricity_8",
				coords = vector3(1609.8883056641, 2539.6389160156, 45.564895629883),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_8", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_9 = {
				name = "repair_electricity_9",
				coords = vector3(1609.0157470703, 2566.9819335938, 45.564903259277),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_9", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_10 = {
				name = "repair_electricity_10",
				coords = vector3(1624.4453125, 2577.6076660156, 45.564891815186),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_10", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_11 = {
				name = "repair_electricity_11",
				coords = vector3(1629.6982421875, 2564.32421875, 45.564907073975),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_11", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_12 = {
				name = "repair_electricity_12",
				coords = vector3(1652.4011230469, 2564.3032226562, 45.564903259277),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_12", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			repair_electricity_13 = {
				name = "repair_electricity_13",
				coords = vector3(1695.7669677734, 2535.9580078125, 45.564849853516),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Souder les circuits",
				aditionalParams = {type = "action", jobIndex = "repair_electricity", zoneIndex = "repair_electricity_13", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			}
		}
	},

	system_check = {
		label = "Vérifier l'état des systèmes de la prison",
		coolDown = 1 * 60 * 10,
		command = "e clipboard",
		timeToWork = {min = 1000 * 30, max = 1000 * 60},
		timeReduction = {min = 1, max = 3},
		zones = {
			system_check_1 = {
				name = "system_check_1",
				coords = vector3(1723.1444091797, 2505.1955566406, 45.564903259277),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_1", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_2 = {
				name = "system_check_2",
				coords = vector3(1718.3187255859, 2487.818359375, 45.564907073975),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_2", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_3 = {
				name = "system_check_3",
				coords = vector3(1667.5288085938, 2487.8479003906, 45.564918518066),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_3", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_4 = {
				name = "system_check_4",
				coords = vector3(1657.2369384766, 2488.4094238281, 45.564910888672),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_4", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_5 = {
				name = "system_check_5",
				coords = vector3(1664.7586669922, 2502.3774414062, 45.564884185791),
				maxDst = 1.75,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_5", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_6 = {
				name = "system_check_6",
				coords = vector3(1617.9742431641, 2521.3415527344, 45.564884185791),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_6", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_7 = {
				name = "system_check_7",
				coords = vector3(1616.5570068359, 2528.0310058594, 45.56489944458),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_7", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_8 = {
				name = "system_check_8",
				coords = vector3(1630.4005126953, 2527.0883789062, 45.564903259277),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_8", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_9 = {
				name = "system_check_9",
				coords = vector3(1632.5909423828, 2529.4697265625, 45.564903259277),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_9", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_10 = {
				name = "system_check_10",
				coords = vector3(1627.9075927734, 2539.3488769531, 45.565010070801),
				maxDst = 1.75,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_10", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_11 = {
				name = "system_check_11",
				coords = vector3(1617.0438232422, 2579.2153320312, 45.564914703369),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_11", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_12 = {
				name = "system_check_12",
				coords = vector3(1634.7973632812, 2553.6247558594, 45.564903259277),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_12", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_13 = {
				name = "system_check_13",
				coords = vector3(1685.7178955078, 2553.6508789062, 45.564846038818),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_13", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_14 = {
				name = "system_check_14",
				coords = vector3(1699.4359130859, 2533.2807617188, 45.564838409424),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_14", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_15 = {
				name = "system_check_15",
				coords = vector3(1790.8029785156, 2568.5832519531, 45.565101623535),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Vérifier l'état des relais",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_15", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			system_check_16 = {
				name = "system_check_16",
				coords = vector3(1767.8985595703, 2531.033203125, 45.565059661865),
				maxDst = 1.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Verifier l'état des hoses",
				aditionalParams = {type = "action", jobIndex = "system_check", zoneIndex = "system_check_16", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			}
		}
	},

	clean_ground = {
		label = "Nettoyer la cour de la prison",
		coolDown = 1 * 60 * 10,
		command = "e leafblower",
		timeToWork = {min = 1000 * 30, max = 1000 * 60},
		timeReduction = {min = 1, max = 3},
		zones = {
			jail_work_clean_ground_1 = {
				name = "jail_work_clean_ground_1",
				coords = vector3(1748.6423339844, 2542.3139648438, 43.585403442383),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_1", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_ground_2 = {
				name = "jail_work_clean_ground_2",
				coords = vector3(1730.1896972656, 2513.62109375, 45.564876556396),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_2", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_ground_3 = {
				name = "jail_work_clean_ground_3",
				coords = vector3(1701.6711425781, 2487.5991210938, 45.564907073975),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_3", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_ground_4 = {
				name = "jail_work_clean_ground_4",
				coords = vector3(1657.4442138672, 2511.8610839844, 45.564907073975),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_4", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_ground_5 = {
				name = "jail_work_clean_ground_5",
				coords = vector3(1634.5913085938, 2537.0876464844, 45.564903259277),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_5", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_ground_6 = {
				name = "jail_work_clean_ground_6",
				coords = vector3(1680.1938476562, 2542.4958496094, 45.56489944458),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_6", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_ground_7 = {
				name = "jail_work_clean_ground_7",
				coords = vector3(1772.1267089844, 2545.8376464844, 45.586502075195),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_7", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			},

			jail_work_clean_ground_8 = {
				name = "jail_work_clean_ground_8",
				coords = vector3(1771.4294433594, 2559.8435058594, 45.586502075195),
				maxDst = 6.0,
				protectEvents = true,
				isKey = true,
				isZone = true,
				nuiLabel = "Passer le souffleur",
				aditionalParams = {type = "action", jobIndex = "clean_ground", zoneIndex = "jail_work_clean_ground_8", fnc = "JailWork"},
				keyMap = {
					checkCoordsBeforeTrigger = true,
					onRelease = true,
					releaseEvent = "on_jail_event",
					key = "E"
				},
				info = {
					doneTime = 0
				}
			}
		}
	}
}

Jail.Guards = {
	{
		pedId = 0, 
		coords = vector3(1827.7591552734, 2618.9887695312, 62.964584350586), 
		heading = 229.21482849121097, 
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01",
	},

	{
		pedId = 0, 
		coords = vector3(1821.7583007812, 2617.0888671875, 62.957973480225), 
		heading = 174.04202270507812, 
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01",
	},

	{
		pedId = 0, 
		coords = vector3(1824.4189453125, 2480.03515625, 62.698795318604), 
		heading = 353.9418640136719, 
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01",
	},

	{
		pedId = 0, 
		coords = vector3(1828.7728271484, 2475.3186035156, 62.69694519043), 
		heading = 280.51123046875, 
		weapon = "weapon_carbinerifle_mk2",
		model = "s_m_m_prisguard_01",
	}
}

Jail.Beds = {
	default = {coords = vector3(1762.1423339844, 2591.5546875, 46.658569335938), heading = 267.2158508300781},
	list = {
		{coords = vector3(1762.1423339844, 2591.5546875, 46.658569335938), heading = 267.2158508300781},
		{coords = vector3(1762.1231689453, 2594.6447753906, 46.658580780029), heading = 270.8278503417969},
		{coords = vector3(1762.0433349609, 2597.7109375, 46.658580780029), heading = 269.0379028320313},
		{coords = vector3(1771.8547363281, 2597.9968261719, 46.658580780029), heading = 95.08554077148438},
		{coords = vector3(1771.86328125, 2594.9226074219, 46.658573150635), heading = 93.82701873779295},
		{coords = vector3(1771.69921875, 2591.818359375, 46.658573150635), heading = 92.20704650878906}
	}
}