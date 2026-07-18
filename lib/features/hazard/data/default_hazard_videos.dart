import '../models/hazard_video.dart';

const defaultHazardVideos = <HazardVideo>[
  HazardVideo(
    id: 'hazard_01',
    title: 'Suburban Street',
    description: 'Watch for pedestrians stepping out between parked cars.',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    durationSeconds: 15,
    category: 'Urban',
    hazardTimestampSeconds: 8,
    order: 1,
  ),
  HazardVideo(
    id: 'hazard_02',
    title: 'Roundabout Approach',
    description: 'Identify when a cyclist enters your path at a mini-roundabout.',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    durationSeconds: 15,
    category: 'Junctions',
    hazardTimestampSeconds: 10,
    order: 2,
  ),
  HazardVideo(
    id: 'hazard_03',
    title: 'Dual Carriageway',
    description: 'Spot the vehicle merging from a slip road onto the main carriageway.',
    videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    durationSeconds: 15,
    category: 'Motorway',
    hazardTimestampSeconds: 11,
    order: 3,
  ),
];
