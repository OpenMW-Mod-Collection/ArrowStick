local I = require('openmw.interfaces')

I.Settings.registerGroup {
    key = 'SettingsArrowStick',
    page = 'ArrowStick',
    l10n = 'ArrowStick',
    name = 'settings_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'despawnArrows',
            name = 'despawnArrows_name',
            description = "despawnArrows_desc",
            renderer = 'checkbox',
            default = false,
        },
        {
            key = 'stickChance',
            name = 'stickChance_name',
            description = "stickChance_desc",
            renderer = 'number',
            default = 1,
            min = -1,
            max = 1,
        },
        {
            key = 'impactEffectsIntegration',
            name = 'impactEffectsIntegration_name',
            description = "impactEffectsIntegration_desc",
            renderer = 'checkbox',
            default = true,
        },
    }
}

if not I.impactEffects then
    I.Settings.updateRendererArgument(
        "SettingsArrowStick",
        "impactEffectsIntegration",
        { disabled = true }
    )
end