# Data Generator for COMP4418 22T3 Project B

import random

NUMBER_OF_FLIGHTS = 1000

ATTRACTION_COST_RANGE = (0,100)

FLIGHT_COST_RANGE = (100,750)

GLOBAL_DAY_RANGE = 365

CITIES = {"sydney":["opera_house",
                    "harbour",
                    "bondi_beach",
                    "botanic_gardens",
                    "taronga_zoo",
                    "centrepoint_tower",
                    "blue_mountains",],
          "melbourne":["phillip_island",
                       "great_ocean_rd",
                       "yarra_valley",
                       "geelong",
                       "bendigo",],
          "brisbane":["south_bank",
                      "surfers_paradise",
                      "gold_coast",
                      "story_bridge",
                      "stradbroke_island",
                      "moreton_island",
                      "sunshine_coast",],
          "adelaide":["glenelg",
                      "central_market",
                      "adelaide_hills",
                      "kangaroo_island",
                      "port_lincoln",],
          "perth":["foreshore",
                   "rottnest_island",
                   "fremantle",
                   "swan_river",
                   "wave_rock"],
          "darwin":["mindil_beach",
                    "waterfront",
                    "berry_springs_national_park",
                    "kakadu",
                    "katherine",],
          "canberra":["parliament_house",
                      "lake_burley_griffin",
                      "questacon",
                      "war_memorial",
                      "national_gallery",
                      "botanic_gardens",],
          "hobart":["bass_strait",
                    "port_arthur",
                    "launceston",
                    "mount_wellington",
                    "cradle_mountain",],
}

CITY_LIST = list(CITIES.keys())

with open('const_data_sample.lp', 'w') as file:
    for city, attractions in CITIES.items():
        file.write(f"city({city}).\n")
        for attraction in attractions:
            file.write(f"attraction({city},{attraction},{random.randint(ATTRACTION_COST_RANGE[0],ATTRACTION_COST_RANGE[1])}).\n")
    
    for _ in range(NUMBER_OF_FLIGHTS):
        dep = random.choice(CITY_LIST)
        arr = random.choice(CITY_LIST)
        while dep == arr:
            arr = random.choice(CITY_LIST)
        date = random.randint(1,GLOBAL_DAY_RANGE)
        cost = random.randint(FLIGHT_COST_RANGE[0],FLIGHT_COST_RANGE[1])
        file.write(f"flight({dep},{arr},{date},{cost}).\n")
        