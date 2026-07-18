const List<Map<String, dynamic>> defaultTheoryQuestions = [
  // --- Alertness ---
  {
    'id': 'q_alert_1',
    'category': 'Alertness',
    'questionText': 'What should you do before moving off from behind a parked car?',
    'options': [
      'Give a signal after moving off',
      'Look around, check blind spots, and signal if necessary',
      'Check only your interior mirror',
      'Flash your headlights to warn other road users'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Before moving off, you must check all mirrors and look around to check your blind spots, ensuring it is completely safe before signaling and moving off.'
  },
  {
    'id': 'q_alert_2',
    'category': 'Alertness',
    'questionText': 'You are driving in heavy rain. Why should you keep a safe distance from the vehicle in front?',
    'options': [
      'To allow you to overtake quickly',
      'In case their brake lights aren\'t working',
      'Because your visibility and braking distance are reduced',
      'To see the road ahead more clearly'
    ],
    'correctOptionIndex': 2,
    'explanation': 'Heavy rain reduces visibility and doubles the braking distance. Keeping a larger gap ensures you have enough time to stop safely.'
  },
  {
    'id': 'q_alert_3',
    'category': 'Alertness',
    'questionText': 'What should you do when you feel sleepy while driving on a motorway?',
    'options': [
      'Speed up to get to your destination quicker',
      'Turn on the radio and roll down the window',
      'Take the next exit or stop at a service station to rest',
      'Stay in the left-hand lane and drive slowly'
    ],
    'correctOptionIndex': 2,
    'explanation': 'If you feel tired or sleepy, stop at a safe place (like a service area or next exit). Never stop on the hard shoulder except in an emergency.'
  },

  // --- Attitude ---
  {
    'id': 'q_att_1',
    'category': 'Attitude',
    'questionText': 'Which vehicle has a flashing amber beacon?',
    'options': [
      'An ambulance in a hurry',
      'A slow-moving vehicle',
      'A doctor on an emergency call',
      'A police car on patrol'
    ],
    'correctOptionIndex': 1,
    'explanation': 'A flashing amber beacon on a vehicle warns other road users that it is a slow-moving vehicle, such as a tractor, road maintenance vehicle, or wide load.'
  },
  {
    'id': 'q_att_2',
    'category': 'Attitude',
    'questionText': 'You are tailgated by a driver who is flashing their headlights. What should you do?',
    'options': [
      'Tap your brakes to warn them to back off',
      'Speed up to increase the gap behind you',
      'Allow them to overtake when it is safe to do so',
      'Turn on your rear fog lights to dazzle them'
    ],
    'correctOptionIndex': 2,
    'explanation': 'If someone is tailgating you, remain calm, maintain a steady speed, and allow them to pass when there is a safe opportunity. Do not react aggressively or break suddenly.'
  },
  {
    'id': 'q_att_3',
    'category': 'Attitude',
    'questionText': 'What should you do when another driver pulls out in front of you, forcing you to brake hard?',
    'options': [
      'Sound your horn and flash your headlights',
      'Stay calm and do not react aggressively',
      'Follow them closely to show your annoyance',
      'Overtake them immediately to get ahead'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Defensive driving means staying calm and focused. Good drivers anticipate errors from other road users and avoid retaliating or acting aggressively.'
  },

  // --- Safety and Your Vehicle ---
  {
    'id': 'q_safe_veh_1',
    'category': 'Safety and Your Vehicle',
    'questionText': 'What is the legal minimum depth of tread for car tires in the UK?',
    'options': [
      '1.0 mm',
      '1.6 mm',
      '2.0 mm',
      '2.5 mm'
    ],
    'correctOptionIndex': 1,
    'explanation': 'The legal minimum tread depth for car tires in the UK is 1.6 mm across the central three-quarters of the breadth of the tread and around the entire circumference.'
  },
  {
    'id': 'q_safe_veh_2',
    'category': 'Safety and Your Vehicle',
    'questionText': 'When should you check your car\'s tire pressures?',
    'options': [
      'After a long motorway journey',
      'When the tires are cold',
      'When the tires are hot',
      'Only when the car is serviced'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Tire pressures should be checked when the tires are cold to get an accurate reading, as driving heats up the tires and temporarily increases pressure.'
  },
  {
    'id': 'q_safe_veh_3',
    'category': 'Safety and Your Vehicle',
    'questionText': 'What will happen if your car\'s wheels are out of balance?',
    'options': [
      'The brakes will fail to work properly',
      'The engine will consume more fuel',
      'The steering will vibrate at certain speeds',
      'The headlights will flicker'
    ],
    'correctOptionIndex': 2,
    'explanation': 'Unbalanced wheels cause the steering wheel to vibrate at certain speeds, which can also lead to premature wear of the steering and suspension.'
  },

  // --- Safety Margins ---
  {
    'id': 'q_margin_1',
    'category': 'Safety Margins',
    'questionText': 'What is the safe separation distance (time gap) from the vehicle in front in dry conditions?',
    'options': [
      '1 second',
      '2 seconds',
      '3 seconds',
      '4 seconds'
    ],
    'correctOptionIndex': 1,
    'explanation': 'In dry conditions, you should leave a time gap of at least 2 seconds between your vehicle and the one in front to react and stop safely.'
  },
  {
    'id': 'q_margin_2',
    'category': 'Safety Margins',
    'questionText': 'What time gap should you leave from the vehicle in front in wet conditions?',
    'options': [
      '2 seconds',
      '4 seconds',
      '6 seconds',
      '8 seconds'
    ],
    'correctOptionIndex': 1,
    'explanation': 'In wet weather, braking distances double, so you should double the safe separation gap to at least 4 seconds.'
  },
  {
    'id': 'q_margin_3',
    'category': 'Safety Margins',
    'questionText': 'What is the main hazard when driving through a ford (shallow water crossing)?',
    'options': [
      'The water depth could flood your exhaust',
      'Your brakes may become wet and less effective',
      'The current could wash your car away',
      'Mud could splash onto your windscreen'
    ],
    'correctOptionIndex': 1,
    'explanation': 'After driving through deep water, always test your brakes immediately because wet brakes are less effective. Press them lightly to dry them out.'
  },

  // --- Hazard Awareness ---
  {
    'id': 'q_hazard_1',
    'category': 'Hazard Awareness',
    'questionText': 'You are driving past parked cars. What is the most significant hazard to watch out for?',
    'options': [
      'Car doors opening or pedestrians stepping out',
      'Drivers flashing their headlights at you',
      'Cars pulling out without signaling',
      'A change in the speed limit'
    ],
    'correctOptionIndex': 0,
    'explanation': 'When passing parked cars, be alert for doors opening, pedestrians stepping out from between cars, or cars pulling out unexpectedly.'
  },
  {
    'id': 'q_hazard_2',
    'category': 'Hazard Awareness',
    'questionText': 'Why should you reduce your speed when driving past a school?',
    'options': [
      'To avoid noise pollution near the school',
      'Children are unpredictable and may run into the road',
      'The speed limit is always 10 mph near schools',
      'To avoid being caught by speed cameras'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Children can easily get distracted and run into the road. Reducing speed gives you more time to stop if a child steps out.'
  },
  {
    'id': 'q_hazard_3',
    'category': 'Hazard Awareness',
    'questionText': 'What does the term \'blind spot\' mean?',
    'options': [
      'An area of the road not visible to the driver in their mirrors',
      'A road junction with poor visibility',
      'Driving at night without headlights',
      'An area blocked by the windscreen wipers'
    ],
    'correctOptionIndex': 0,
    'explanation': 'A blind spot is an area around the vehicle that cannot be seen by looking in the mirrors. You must look over your shoulder to check these areas.'
  },

  // --- Vulnerable Road Users ---
  {
    'id': 'q_vuln_1',
    'category': 'Vulnerable Road Users',
    'questionText': 'Why should you give motorcyclists extra room when they are overtaking you?',
    'options': [
      'They are faster than you',
      'They can be blown off course by strong side winds',
      'They have a right of way over cars',
      'They need room to perform stunts'
    ],
    'correctOptionIndex': 1,
    'explanation': 'High winds or drafts from large vehicles can blow motorcyclists and cyclists off course. Always give them plenty of room.'
  },
  {
    'id': 'q_vuln_2',
    'category': 'Vulnerable Road Users',
    'questionText': 'You see a pedestrian with a white cane with a red band. What does this indicate?',
    'options': [
      'They are deaf',
      'They are blind',
      'They are both deaf and blind',
      'They are elderly'
    ],
    'correctOptionIndex': 2,
    'explanation': 'A white cane with a red reflective band indicates that the pedestrian is both deaf and blind.'
  },
  {
    'id': 'q_vuln_3',
    'category': 'Vulnerable Road Users',
    'questionText': 'What should you do when passing a horse and rider?',
    'options': [
      'Sound your horn to warn them',
      'Rev your engine to pass quickly',
      'Drive past slowly and give them plenty of room',
      'Flash your headlights'
    ],
    'correctOptionIndex': 2,
    'explanation': 'Horses are easily frightened by loud noises. You should slow down, drive past very slowly, and give them plenty of room. Do not rev your engine or blow your horn.'
  },

  // --- Other Types of Vehicle ---
  {
    'id': 'q_other_veh_1',
    'category': 'Other Types of Vehicle',
    'questionText': 'Why should you keep well back when following a large goods vehicle?',
    'options': [
      'To avoid exhaust fumes',
      'To allow the driver to see you in their mirrors',
      'To block other cars from cutting in',
      'To stay out of their slipstream'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Large vehicles block your view of the road ahead. Keeping well back improves your view and lets the truck driver see you in their side mirrors.'
  },
  {
    'id': 'q_other_veh_2',
    'category': 'Other Types of Vehicle',
    'questionText': 'You are following a large vehicle that is approaching a roundabout. The driver signals left but moves to the right. What should you do?',
    'options': [
      'Overtake them on the left',
      'Sound your horn to warn them',
      'Stay well back and let them complete their turn',
      'Overtake them on the right'
    ],
    'correctOptionIndex': 2,
    'explanation': 'Large vehicles need extra room to maneuver. They may swing out to the right before turning left. Give them space and do not try to pass them.'
  },
  {
    'id': 'q_other_veh_3',
    'category': 'Other Types of Vehicle',
    'questionText': 'What should you do when an emergency vehicle with flashing blue lights is behind you?',
    'options': [
      'Brake hard immediately',
      'Speed up to stay ahead',
      'Pull over safely to the side to let it pass',
      'Stop in the middle of the road'
    ],
    'correctOptionIndex': 2,
    'explanation': 'You should help the emergency vehicle by pulling over safely to allow it to pass. Do not panic, brake suddenly, or block its path.'
  },

  // --- Vehicle Handling ---
  {
    'id': 'q_handle_1',
    'category': 'Vehicle Handling',
    'questionText': 'What is the main cause of skidding?',
    'options': [
      'Worn steering components',
      'Driving too fast for the road conditions',
      'Poor tire inflation',
      'Driving in the wrong gear'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Skidding is almost always caused by driver error, such as braking too hard, steering too sharply, or driving too fast for the road conditions.'
  },
  {
    'id': 'q_handle_2',
    'category': 'Vehicle Handling',
    'questionText': 'How should you steer if your car starts to skid on ice?',
    'options': [
      'Steer away from the direction of the skid',
      'Steer into the direction of the skid',
      'Keep the steering wheel completely straight',
      'Brake hard and steer sharply'
    ],
    'correctOptionIndex': 1,
    'explanation': 'If your vehicle starts to skid, you should steer in the direction of the skid (the way the back of the car is sliding) and release the pedals to regain traction.'
  },
  {
    'id': 'q_handle_3',
    'category': 'Vehicle Handling',
    'questionText': 'Why is coasting (driving in neutral or with the clutch held down) dangerous?',
    'options': [
      'It increases fuel consumption',
      'It reduces your control over the steering and braking',
      'It damages the gearbox',
      'It causes the engine to stall'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Coasting reduces the driver\'s control because there is no engine braking, and the vehicle can pick up speed quickly on descents.'
  },

  // --- Motorway Rules ---
  {
    'id': 'q_motor_1',
    'category': 'Motorway Rules',
    'questionText': 'What is the national speed limit for a car on a motorway in the UK?',
    'options': [
      '60 mph',
      '70 mph',
      '80 mph',
      '50 mph'
    ],
    'correctOptionIndex': 1,
    'explanation': 'The national speed limit for cars on a motorway is 70 mph, unless signs indicate a temporary lower limit.'
  },
  {
    'id': 'q_motor_2',
    'category': 'Motorway Rules',
    'questionText': 'When are you allowed to drive on the hard shoulder of a motorway?',
    'options': [
      'To check your map or GPS',
      'In an emergency or if directed by signs or police',
      'To make a phone call',
      'To avoid heavy traffic congestion'
    ],
    'correctOptionIndex': 1,
    'explanation': 'The hard shoulder must only be used in an emergency (such as a breakdown) or when instructed by active road signs or traffic officers.'
  },
  {
    'id': 'q_motor_3',
    'category': 'Motorway Rules',
    'questionText': 'What color are the reflective studs between the motorway lanes?',
    'options': [
      'Red',
      'Amber',
      'White',
      'Green'
    ],
    'correctOptionIndex': 2,
    'explanation': 'White studs are used to mark the lanes on a motorway. Red studs mark the left edge, amber studs mark the right edge next to the central reservation, and green studs mark slip road exits/entries.'
  },

  // --- Rules of the Road ---
  {
    'id': 'q_rules_1',
    'category': 'Rules of the Road',
    'questionText': 'Who has priority at an unmarked crossroads?',
    'options': [
      'The driver on the wider road',
      'No one has priority',
      'The driver turning right',
      'The first driver to arrive'
    ],
    'correctOptionIndex': 1,
    'explanation': 'No one has priority at an unmarked crossroads. Everyone must proceed with extreme caution and look out for other vehicles.'
  },
  {
    'id': 'q_rules_2',
    'category': 'Rules of the Road',
    'questionText': 'What is the national speed limit for cars on a single carriageway road in the UK?',
    'options': [
      '50 mph',
      '60 mph',
      '70 mph',
      '40 mph'
    ],
    'correctOptionIndex': 1,
    'explanation': 'The national speed limit for cars on a single carriageway road in the UK is 60 mph.'
  },
  {
    'id': 'q_rules_3',
    'category': 'Rules of the Road',
    'questionText': 'You see double yellow lines on the side of the road. What do they mean?',
    'options': [
      'No parking at any time',
      'No stopping at any time',
      'Parking is allowed with a permit',
      'Loading is permitted on weekends only'
    ],
    'correctOptionIndex': 0,
    'explanation': 'Double yellow lines indicate that parking or waiting is prohibited at any time, unless signs state seasonal rules.'
  },

  // --- Road and Traffic Signs ---
  {
    'id': 'q_sign_1',
    'category': 'Road and Traffic Signs',
    'questionText': 'What shape is a standard stop sign?',
    'options': [
      'Circular',
      'Triangular',
      'Octagonal',
      'Rectangular'
    ],
    'correctOptionIndex': 2,
    'explanation': 'A Stop sign is octagonal (eight-sided) to make it easily recognizable even when covered in snow, dirt, or viewed from behind.'
  },
  {
    'id': 'q_sign_2',
    'category': 'Road and Traffic Signs',
    'questionText': 'What does a red triangular sign mean?',
    'options': [
      'An order or prohibition',
      'A warning of potential hazards',
      'Information or directions',
      'A speed limit order'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Triangular signs with red borders are warning signs that alert drivers to hazards ahead.'
  },
  {
    'id': 'q_sign_3',
    'category': 'Road and Traffic Signs',
    'questionText': 'What does a blue circular sign with a speed number (e.g. 30) indicate?',
    'options': [
      'Maximum speed limit',
      'Recommended speed limit',
      'Minimum speed limit',
      'Advisory parking speed'
    ],
    'correctOptionIndex': 2,
    'explanation': 'Blue circular signs indicate a positive instruction or command. When displaying a speed number, it indicates a minimum speed limit.'
  },

  // --- Essential Documents ---
  {
    'id': 'q_doc_1',
    'category': 'Essential Documents',
    'questionText': 'What is the main purpose of an MOT certificate?',
    'options': [
      'To verify ownership of the vehicle',
      'To check the mechanical safety and emissions of the car',
      'To record the car\'s service history',
      'To validate the insurance premium'
    ],
    'correctOptionIndex': 1,
    'explanation': 'The MOT test checks that your vehicle meets road safety and environmental standards. It is required annually for cars over three years old.'
  },
  {
    'id': 'q_doc_2',
    'category': 'Essential Documents',
    'questionText': 'What is the legal requirement for vehicle insurance in the UK?',
    'options': [
      'Fully comprehensive cover',
      'Third-party only cover',
      'Personal injury protection',
      'No insurance is required'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Third-party cover is the legal minimum insurance requirement in the UK to drive on public roads.'
  },
  {
    'id': 'q_doc_3',
    'category': 'Essential Documents',
    'questionText': 'What document is required to prove you are the registered keeper of a vehicle?',
    'options': [
      'MOT certificate',
      'Driving license',
      'V5C registration document (Logbook)',
      'Insurance certificate'
    ],
    'correctOptionIndex': 2,
    'explanation': 'The V5C (also known as the logbook) is the official registration document that shows who is the registered keeper of the vehicle.'
  },

  // --- Incidents, Accidents and Emergencies ---
  {
    'id': 'q_inc_1',
    'category': 'Incidents, Accidents and Emergencies',
    'questionText': 'What should you do first if your car breaks down on a motorway?',
    'options': [
      'Call a mechanic immediately from inside the car',
      'Pull onto the hard shoulder, turn on hazard lights, and stand behind the crash barrier',
      'Walk to the nearest exit to seek help',
      'Stand in front of your car to warn oncoming vehicles'
    ],
    'correctOptionIndex': 1,
    'explanation': 'If your vehicle breaks down on the motorway, get it to the hard shoulder, put on hazard lights, get all occupants out of the car, and wait behind the safety barrier away from traffic.'
  },
  {
    'id': 'q_inc_2',
    'category': 'Incidents, Accidents and Emergencies',
    'questionText': 'You arrive at the scene of a crash. A casualty is unconscious but breathing. What should you do?',
    'options': [
      'Give them water to drink',
      'Move them into the recovery position',
      'Slap their face to wake them up',
      'Leave them in the vehicle and walk away'
    ],
    'correctOptionIndex': 1,
    'explanation': 'If an injured person is unconscious but breathing, place them in the recovery position to keep their airway open, and monitor them until emergency help arrives.'
  },
  {
    'id': 'q_inc_3',
    'category': 'Incidents, Accidents and Emergencies',
    'questionText': 'What does a flashing red light above a motorway lane indicate?',
    'options': [
      'The speed limit has changed',
      'The lane is closed and you must not proceed in it',
      'Roadworks are ahead in 1 mile',
      'Normal driving conditions apply'
    ],
    'correctOptionIndex': 1,
    'explanation': 'A flashing red light or red \'X\' above a lane indicates that the lane is closed and you must not drive in it.'
  },

  // --- Pedestrian Crossings ---
  {
    'id': 'q_cross_1',
    'category': 'Pedestrian Crossings',
    'questionText': 'What should you do when approaching a pedestrian crossing where people are waiting to cross?',
    'options': [
      'Wave at them to cross',
      'Sound your horn to warn them',
      'Slow down and prepare to stop',
      'Drive past quickly before they step out'
    ],
    'correctOptionIndex': 2,
    'explanation': 'You should slow down when approaching a crossing. If anyone is waiting to cross, be prepared to stop and let them cross safely.'
  },
  {
    'id': 'q_cross_2',
    'category': 'Pedestrian Crossings',
    'questionText': 'What type of crossing has a flashing amber light cycle?',
    'options': [
      'Pelican crossing',
      'Zebra crossing',
      'Puffin crossing',
      'Toucan crossing'
    ],
    'correctOptionIndex': 0,
    'explanation': 'A Pelican crossing has a flashing amber light. This means you must give way to any pedestrians on the crossing, but can proceed if it is completely clear.'
  },
  {
    'id': 'q_cross_3',
    'category': 'Pedestrian Crossings',
    'questionText': 'What is the main difference between a Puffin crossing and a Pelican crossing?',
    'options': [
      'Puffin crossings are only for cyclists',
      'Puffin crossings have smart sensors that detect when pedestrians have finished crossing',
      'Pelican crossings have no traffic lights',
      'Puffin crossings are manual and have no sensors'
    ],
    'correctOptionIndex': 1,
    'explanation': 'Puffin crossings use sensors to detect if pedestrians are still crossing, adjusting the light duration dynamically. They do not have a flashing amber phase.'
  }
];
