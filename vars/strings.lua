require("__heroic-library__.vars.words")
require("__heroic-library__.vars.strings")

-- Combined
SciencePack = combine{Science, Pack}
ResearchUpgrade = combine{Research, Upgrade}
RoboportMaterialStorage = combine{Roboport, Material, Storage}
RoboportRobotStorage = combine{Roboport, Robot, Storage}
RoboportEnergy = combine{Energy, Roboport}
RoboportEfficiency = combine{Roboport, Efficiency}
RoboportProductivity = combine{Roboport, Productivity}
RoboportSpeed = combine{Roboport, Speed}
RoboportConstructionArea = combine{Roboport, Construction, Area}
RoboportLogisticArea = combine{Roboport, Logistic, Area}
RoboportUpdater = combine{Roboport, Updater}
RoboportLogistical = combine{Logistical, Roboport}
RoboportLogisticalLeveled = combine{RoboportLogistical, Mark}
RoboportEnergyLeveled = combine{RoboportEnergy, Mark}
FlyingRobotFrame = combine{Flying, Robot, Frame}

EfficiencyResearchLevel = combine{Efficiency, Research, Level}
ProductivityResearchLevel = combine{Productivity, Research, Level}
SpeedResearchLevel = combine{Speed, Research, Level}
ConstructionAreaResearchLevel = combine{Construction, Area, Research, Level}
LogisticAreaResearchLevel = combine{Logistic, Area, Research, Level}
RobotStorageResearchLevel = combine{Robot, Storage, Research, Level}
MaterialStorageResearchLevel = combine{Material, Storage, Research, Level}
roboports_to_update = combine{Roboport, Updater}
ghosts_to_update = combine{Entity, Ghost, Updater}

MetallurgicSciencePack = combine{Metallurgic, SciencePack}
ElectromagneticSciencePack = combine{Electromagnetic, SciencePack}
AgriculturalSciencePack = combine{Agricultural, SciencePack}
CryogenicSciencePack = combine{Cryogenic, SciencePack}
PromethiumSciencePack = combine{Promethium, SciencePack}

-- Settings
RobotStorageLimit = combine{Robot, Storage, Limit}
ResearchMinimum =  combine{Research, Minimum}
ResearchMaximum = combine{Research, Maximum}
EnergyEfficiencyLimit = combine{Energy, Efficiency, Limit}
EnergyProductivityLimit = combine{Energy, Productivity, Limit}
EnergySpeedLimit = combine{Energy, Speed, Limit}
InputFlowLimitModifier = combine{Input, Flow, Limit, Modifier}
BufferCapacityModifier = combine{Buffer, Capacity, Modifier}
RechargeMinimumModifier = combine{Recharge, Minimum, Modifier}
EnergyUsageModifier = combine{Energy, Usage, Modifier}
ChargingEnergyModifier = combine{Charging, Energy, Modifier}
ConstructionAreaLimit = combine{Construction, Area, Limit}
LogisticAreaLimit = combine{Logistic, Area, Limit}
MaterialStorageLimit = combine{Material, Storage, Limit}
RoboportResearchUpgradeCost = combine{Research, Upgrade, Cost}
RoboportResearchUpgradeTime = combine{Research, Upgrade, Time}
UpgradeTimer = combine{Upgrade, Timer}
ShowItems = combine{Show, Items}
