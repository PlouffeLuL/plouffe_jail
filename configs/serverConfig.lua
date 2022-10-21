Lang = exports.plouffe_lib:Get("Lang")

Server = {
	ready = false
}

Jail = {
	frameWork = GetConvar("plouffe_lib:framework"),
	comServ = {
		coords = vector3(1113.8276367188, -648.86486816406, 57.750007629395),
		jobs = {
			comserv_clean_ground = {
				duration = 30000,
				anim = {dict = 'amb@world_human_gardener_leaf_blower@base', clip = 'base'},
				prop = {bone = 28422, model = `prop_leaf_blower_01`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
				distance = 6,
				isZone = true,
				label = "Passer le soufleur",
				params = {job_type = "clean_ground", job_index = ""},
				keyMap = {
					key = "E",
					event = "plouffe_jail:onComServ_Work"
				},
				coords = {
					vector3(1144.5314941406, -644.07501220703, 56.855709075928),
					vector3(1127.8784179688, -646.75836181641, 56.826984405518),
					vector3(1144.5382080078, -712.00073242188, 56.708030700684),
					vector3(1057.5083007813, -719.93017578125, 56.735481262207),
					vector3(1060.8468017578, -614.62078857422, 56.754543304443)
				}
			},
			comserv_clean_drink = {
				duration = 30000,
				anim = {dict = 'timetable@floyd@clean_kitchen@base', clip = 'base'},
				prop = {bone = 28422, model = `prop_sponge_01`, pos = vec3(0.0, 0.0, -0.01), rot = vec3(90.0, 0.0, 0.0) },
				distance = 0.5,
				isZone = true,
				label = "Nettoyer",
				params = {job_type = "clean_water_drink_stuff", job_index = ""},
				keyMap = {
					key = "E",
					event = "plouffe_jail:onComServ_Work"
				},
				coords = {
					vector3(1126.5113525391, -665.25347900391, 56.757286071777),
					vector3(1137.2478027344, -736.75909423828, 56.855751037598),
					vector3(1052.8720703125, -710.60009765625, 56.843505859375),
					vector3(1061.4716796875, -608.58551025391, 56.800880432129),
					vector3(1131.0853271484, -600.55328369141, 56.788669586182)
				}
			},
			comserv_broom_floor = {
				duration = 30000,
				anim = {dict = 'anim@amb@drug_field_workers@rake@male_a@base', clip = 'base', flag = 1},
				prop = {bone = 28422, model = `prop_tool_broom`, pos = vec3(-0.0100, 0.0400, -0.0300), rot = vec3(0.0, 0.0, 0.0)},
				distance = 1.0,
				isZone = true,
				label = "Passer le soufleur",
				params = {job_type = "broom_floor", job_index = ""},
				keyMap = {
					key = "E",
					event = "plouffe_jail:onComServ_Work"
				},
				coords = {
					vector3(1109.1571044922, -631.74468994141, 56.816036224365),
					vector3(1114.5059814453, -660.85668945313, 56.813186645508),
					vector3(1075.6676025391, -707.90222167969, 57.515033721924),
					vector3(1071.2813720703, -712.10003662109, 58.483585357666),
					vector3(1065.7161865234, -716.740234375, 57.473072052002),
					vector3(1117.8043212891, -656.75061035156, 56.813179016113),
					vector3(1112.0157470703, -645.89270019531, 56.816040039063)
				}
			}
		},
		jobs_zones = {}
	},
	releasedCoords = vector3(1836.2176513672, 2594.3996582031, 46.01439666748),
	pictureCoords = vector4(1844.3754882813, 2594.3928222656, 46.016227722168, 90.991333007813),
	breakOutCoords = vector3(2749.1469726563, 1578.384765625, 50.68688583374),
	cells = {
		vector3(1758.6975097656, 2472.3298339844, 45.740753173828),
		vector3(1761.6942138672, 2474.4475097656, 45.740753173828),
		vector3(1764.4400634766, 2476.6166992188, 45.740768432617),
		vector3(1767.5684814453, 2478.1223144531, 45.740718841553),
		vector3(1770.9582519531, 2479.591796875, 45.740783691406),
		vector3(1774.3774414063, 2481.6057128906, 45.740776062012),
		vector3(1777.5574951172, 2483.5090332031, 45.740787506104),
		vector3(1767.5850830078, 2500.85546875, 45.740783691406),
		vector3(1764.2955322266, 2499.0080566406, 45.740776062012),
		vector3(1761.0816650391, 2497.3891601563, 45.740787506104),
		vector3(1754.7265625, 2493.9152832031, 45.740745544434),
		vector3(1751.9959716797, 2491.837890625, 45.740745544434),
		vector3(1748.7708740234, 2490.095703125, 45.740779876709),
		vector3(1767.5126953125, 2501.228515625, 49.69303894043),
		vector3(1764.9465332031, 2498.8583984375, 49.693042755127),
		vector3(1761.1639404297, 2497.1982421875, 49.69303894043),
		vector3(1758.4038085938, 2495.3322753906, 49.69303894043),
		vector3(1755.1333007813, 2493.5163574219, 49.69303894043),
		vector3(1751.7418212891, 2492.0095214844, 49.69303894043),
		vector3(1749.1137695313, 2489.6333007813, 49.693042755127),
		vector3(1758.6501464844, 2472.3034667969, 49.693042755127),
		vector3(1761.6934814453, 2474.5734863281, 49.693042755127),
		vector3(1764.3494873047, 2475.9653320313, 49.693042755127),
		vector3(1767.8245849609, 2477.8422851563, 49.69303894043),
		vector3(1771.1726074219, 2479.7145996094, 49.693042755127),
		vector3(1774.3846435547, 2481.88671875, 49.69303894043),
		vector3(1777.5385742188, 2483.4982910156, 49.69303894043)
	},
	zones = {
		jail_sector = {
			name = "jail_sector",
			isZone = true,
			zMax = 55.0,
			zMin = 38.0,
			distance = 160,
			coords = vector3(1705.2960205078, 2525.8703613281, 45.564846038818),
			zoneMap = {
			  inEvent = "plouffe_jail:inJail",
			  outEvent = "plouffe_jail:outsideJail"
			}
		},

		jail_stupid = {
			name = "jail_stupid",
			isZone = true,
			zMax = 62,
			zMin = 48,
			coords = {
				vector3(1826.2233886719, 2568.3862304688, 50.438812255859),
				vector3(1825.5397949219, 2596.3833007813, 50.438812255859),
				vector3(1845.0703125, 2596.720703125, 50.438812255859),
				vector3(1845.212890625, 2568.3942871094, 50.438812255859)
			},
			zoneMap = {
				inEvent = "plouffe_jail:imStupid",
				outEvent = "plouffe_jail:notStupid"
			}
		},

		jail_sector_mid = {
			name = "jail_sector_mid",
			isZone = true,
			zMin = 38.0,
			distance = 100,
			coords = vector3(1837.7553710938, 2574.9887695313, 50.443782806396),
			zoneMap = {
			  inEvent = "plouffe_jail:in_mid",
			  outEvent = "plouffe_jail:outside_mid"
			}
		},

		jail_yoga_1 = {
			name = "jail_yoga_1",
			isZone = true,
			distance = 0.7,
			coords = vector3(1744.8018798828, 2477.916015625, 45.759197235107),
			label = "Yoga",
			keyMap = {
				key = "E",
				event = "plouffe_jail:onYoga"
			}
		},

		jail_yoga_2 = {
			name = "jail_yoga_2",
			isZone = true,
			distance = 0.7,
			coords = vector3(1743.80859375, 2479.2072753906, 45.759349822998),
			label = "Yoga",
			keyMap = {
				key = "E",
				event = "plouffe_jail:onYoga"
			}
		},

		jail_yoga_3 = {
			name = "jail_yoga_3",
			isZone = true,
			distance = 0.7,
			coords = vector3(1743.0496826172, 2480.7268066406, 45.759334564209),
			label = "Yoga",
			keyMap = {
				key = "E",
				event = "plouffe_jail:onYoga"
			}
		},

		jail_clothing = {
			name = "jail_clothing",
			isZone = true,
			distance = 0.7,
			coords = vector3(1746.6778564453, 2481.7138671875, 45.740688323975),
			label = "Vetements",
			keyMap = {
				key = "E",
				event = "plouffe_jail:onClothing"
			}
		},

		jail_release = {
			name = "jail_release",
			coords = vector3(1827.9693603516, 2579.8237304688, 46.014301300049),
			distance = 1.0,
			isZone = true,
			label = "Parler avec le garde",
			keyMap = {
				event = "plouffe_jail:onGuardInteraction",
				key = "E"
			},
			ped = {
				coords = vector3(1827.9693603516, 2579.8237304688, 46.014301300049),
				heading = 0.16944895684719,
				model = 's_m_m_prisguard_01'
			}
		},

		jail_illegal_shop = {
			name = "jail_illegal_shop",
			coords = vector3(1751.7360839844, 2535.4787597656, 43.58544921875),
			distance = 2.0,
			isZone = true,
			label = "Voir les echanges possible",
			keyMap = {
				event = "plouffe_jail:open_shop",
				key = "E"
			},
			ped = {
				coords = vector3(1751.7360839844, 2535.4787597656, 43.58544921875),
				heading = 26.23263359069824,
				model = 's_m_y_prismuscl_01',
			}
		},

		comServ_sector = {
			name = "comServ_sector",
			isZone = true,
			distance = 70,
			zMax = 74.3,
			zMin = 49.5,
			coords = {
				vector3(1041.9793701172, -533.47052001953, 61.310836791992),
				vector3(1100.3156738281, -522.79187011719, 63.374767303467),
				vector3(1152.5814208984, -523.39459228516, 64.858680725098),
				vector3(1180.6265869141, -751.51263427734, 57.944431304932),
				vector3(1052.1011962891, -745.77587890625, 57.956470489502),
				vector3(1028.0258789063, -726.91540527344, 57.695407867432),
				vector3(993.46612548828, -672.12829589844, 57.313465118408),
				vector3(1019.4408569336, -651.77105712891, 58.813140869141)
			},
			zoneMap = {
			  inEvent = "plouffe_jail:inComserv",
			  outEvent = "plouffe_jail:outsideComserv"
			}
		},

		comserv_guard = {
			name = "comserv_guard",
			coords = vector3(1113.6188964844, -637.56158447266, 56.812908172607),
			distance = 1.0,
			isZone = true,
			label = "Parler avec le garde",
			keyMap = {
				event = "plouffe_jail:onComservGuardInteraction",
				key = "E"
			},
			ped = {
				coords = vector3(1113.6188964844, -637.56158447266, 56.812908172607),
				heading = 102.79093933105,
				model = 's_m_m_prisguard_01'
			}
		}
	},
	jobs = {
		clean_glass = {
			duration = 10000,
			anim = {dict = 'amb@world_human_maid_clean@', clip = 'base'},
			prop = {bone = 28422, model = `prop_sponge_01`, pos = vec3(0.0, 0.0, -0.01), rot = vec3(90.0, 0.0, 0.0) },
			reduceValue = {min = 1, max = 5},
			distance = 1,
			isZone = true,
			label = "Nettoyer la vitrine",
			params = {job_type = "clean_glass", job_index = "jail_clean_glass_%s"},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1771.1712646484, 2565.9812011719, 45.586566925049),
				vector3(1761.4769287109, 2568.986328125, 45.565093994141),
				vector3(1716.4619140625, 2569.1071777344, 45.56489944458),
				vector3(1665.1164550781, 2569.1215820312, 45.564884185791),
				vector3(1792.3651123047, 2547.9216308594, 45.565097808838),
				vector3(1792.4301757812, 2556.2360839844, 45.565093994141),
				vector3(1792.6055908203, 2578.4067382812, 45.565086364746),
				vector3(1793.0196533203, 2587.7067871094, 45.565090179443)
			}
		},
		fix_electricity = {
			duration = 10000,
			anim = {scenario = "WORLD_HUMAN_WELDING"},
			reduceValue = {min = 1, max = 3},
			distance = 1,
			isZone = true,
			label = "Reparer le systeme",
			params = {job_type = "fix_electricity", job_index = ""},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1760.6419677734, 2519.1494140625, 45.565086364746),
				vector3(1737.4404296875, 2504.6823730469, 45.565086364746),
				vector3(1706.8850097656, 2481.072265625, 45.564922332764),
				vector3(1700.2322998047, 2474.8959960938, 45.564979553223),
				vector3(1679.7576904297, 2480.1789550781, 45.564968109131),
				vector3(1644.0231933594, 2490.8410644531, 45.564903259277),
				vector3(1622.4432373047, 2507.6843261719, 45.564907073975),
				vector3(1609.8883056641, 2539.6389160156, 45.564895629883),
				vector3(1609.0157470703, 2566.9819335938, 45.564903259277),
				vector3(1624.4453125, 2577.6076660156, 45.564891815186),
				vector3(1629.6982421875, 2564.32421875, 45.564907073975),
				vector3(1652.4011230469, 2564.3032226562, 45.564903259277),
				vector3(1695.7669677734, 2535.9580078125, 45.564849853516)
			}
		},
		check_systems = {
			duration = 10000,
			anim = {dict = 'missfam4', clip = 'base'},
			prop = {bone = 36029, model = `p_amb_clipboard_01`, pos = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0) },
			reduceValue = {min = 1, max = 3},
			distance = 1,
			isZone = true,
			label = "Verifier le reseau",
			params = {job_type = "check_systems", job_index = ""},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1723.1444091797, 2505.1955566406, 45.564903259277),
				vector3(1718.3187255859, 2487.818359375, 45.564907073975),
				vector3(1667.5288085938, 2487.8479003906, 45.564918518066),
				vector3(1657.2369384766, 2488.4094238281, 45.564910888672),
				vector3(1664.7586669922, 2502.3774414062, 45.564884185791),
				vector3(1617.9742431641, 2521.3415527344, 45.564884185791),
				vector3(1616.5570068359, 2528.0310058594, 45.56489944458),
				vector3(1630.4005126953, 2527.0883789062, 45.564903259277),
				vector3(1632.5909423828, 2529.4697265625, 45.564903259277),
				vector3(1627.9075927734, 2539.3488769531, 45.565010070801),
				vector3(1617.0438232422, 2579.2153320312, 45.564914703369),
				vector3(1634.7973632812, 2553.6247558594, 45.564903259277),
				vector3(1685.7178955078, 2553.6508789062, 45.564846038818),
				vector3(1699.4359130859, 2533.2807617188, 45.564838409424),
				vector3(1790.8029785156, 2568.5832519531, 45.565101623535),
				vector3(1767.8985595703, 2531.033203125, 45.565059661865)
			}
		},
		clean_ground = {
			duration = 10000,
			anim = {dict = 'amb@world_human_gardener_leaf_blower@base', clip = 'base'},
			prop = {bone = 28422, model = `prop_leaf_blower_01`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			reduceValue = {min = 1, max = 3},
			distance = 6,
			isZone = true,
			label = "Passer le soufleur",
			params = {job_type = "clean_ground", job_index = ""},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1748.6423339844, 2542.3139648438, 43.585403442383),
				vector3(1730.1896972656, 2513.62109375, 45.564876556396),
				vector3(1701.6711425781, 2487.5991210938, 45.564907073975),
				vector3(1657.4442138672, 2511.8610839844, 45.564907073975),
				vector3(1634.5913085938, 2537.0876464844, 45.564903259277),
				vector3(1680.1938476562, 2542.4958496094, 45.56489944458),
				vector3(1772.1267089844, 2545.8376464844, 45.586502075195),
				vector3(1771.4294433594, 2559.8435058594, 45.586502075195)
			}
		},
		clean_kitchen = {
			duration = 20000,
			anim = {dict = 'move_mop', clip = 'idle_scrub_small_player'},
			prop = {bone = 28422, model = `prop_cs_mop_s`, pos = vec3(0.0, 0.0, 0.12), rot = vec3(0.0, 0.0, 0.0) },
			reduceValue = {min = 1, max = 3},
			distance = 1.5,
			isZone = true,
			label = "Passer le soufleur",
			params = {job_type = "clean_kitchen", job_index = ""},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1787.7946777344, 2548.9516601563, 45.673076629639),
				vector3(1780.9490966797, 2549.1203613281, 45.673076629639),
				vector3(1786.7486572266, 2556.607421875, 45.673076629639)
			}
		},
		clean_cell_block = {
			duration = 20000,
			anim = {dict = 'anim@amb@drug_field_workers@rake@male_a@base', clip = 'base', flag = 1},
			prop = {bone = 28422, model = `prop_tool_broom`, pos = vec3(-0.0100, 0.0400, -0.0300), rot = vec3(0.0, 0.0, 0.0)},
			reduceValue = {min = 1, max = 3},
			distance = 1.0,
			isZone = true,
			label = "Passer le soufleur",
			params = {job_type = "clean_cell_block", job_index = ""},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1768.2550048828, 2493.0400390625, 45.740715026855),
				vector3(1766.5397949219, 2485.0771484375, 45.740779876709),
				vector3(1758.3238525391, 2482.5610351563, 45.740768432617)
			}
		},
		train_arms = {
			duration = 30000,
			anim = {dict = 'amb@world_human_muscle_free_weights@male@barbell@base', clip = 'base'},
			prop = {bone = 28422, model = `prop_curl_bar_01`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0)},
			reduceValue = {min = 4, max = 8},
			distance = 0.5,
			isZone = true,
			label = "Passer le soufleur",
			params = {job_type = "train_arms", job_index = ""},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1642.4366455078, 2524.2563476563, 45.564819335938),
				vector3(1645.34375, 2536.943359375, 45.564872741699),
				vector3(1638.9710693359, 2527.9973144531, 45.565399169922)
			}
		},
		train_traps = {
			duration = 30000,
			anim = {dict = 'amb@world_human_muscle_free_weights@male@barbell@idle_a', clip = 'idle_d'},
			prop = {bone = 28422, model = `prop_curl_bar_01`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0)},
			reduceValue = {min = 4, max = 8},
			distance = 0.5,
			isZone = true,
			label = "Passer le soufleur",
			params = {job_type = "train_traps", job_index = ""},
			keyMap = {
				key = "E",
				event = "plouffe_jail:onWork"
			},
			coords = {
				vector3(1644.2288818359, 2522.8071289063, 45.564846038818),
				vector3(1646.6285400391, 2536.0107421875, 45.564868927002),
				vector3(1643.3571777344, 2533.5805664063, 45.564884185791)
			}
		}
	},
	jobs_zones = {},
	buyable_items = {}
}