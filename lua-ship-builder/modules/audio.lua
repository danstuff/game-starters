Audio = {}

--module attributes
Audio.priority = 3
Audio.cmd = { "audio", "aud" }

Audio.set_file = "audio_settings.dat"
Audio.set = {
    sound_vol = 10,
    music_vol = 5,

    sound_folder = "resources/sound/",
    music_folder = "resources/music/"

    --place IDs here
}

function Audio.init()
    Audio.set.sound_vol = Util.range(Audio.set.sound_vol, 0, 10)
    Audio.set.music_vol = Util.range(Audio.set.music_vol, 0, 10)

    --load music 
    Audio.musics = {}
    Audio.loadAudio(Audio.set.music_folder, Audio.musics, 
                    Audio.set.music_vol)
    
    --load sound
    Audio.sounds = {}
    Audio.loadAudio(Audio.set.sound_folder, Audio.sounds, 
                    Audio.set.sound_vol, "static")
end

function Audio.loadAudio(folder, tbl, vol, state)
    Util.fordir(folder,
        function(file)
            local src = love.audio.newSource(file, state)
            src:setVolume(vol)
            table.insert(tbl, src)
        end)
end

function Audio.playSound(sound_id)
    Audio.sounds[sound_id]:play()
end

function Audio.playMusic(music_id)
    --stop all other musics
    for id,music in pairs(Audio.musics) do
        if id ~= music_id then music:stop() end
    end

    Audio.musics[music_id]:setLooping(true)
    Audio.musics[music_id]:play()
end

return Audio
