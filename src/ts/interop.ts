import * as Bounce from "./bounce";
import * as Cache from "./cache";
import * as Audio from "./audio";
import { Elm } from "../elm/Main";

export function bindPorts(app: Elm.Main.App) {
  const {
    playIntroMusic,
    introMusicPlaying,
    fadeMusic,
    generateBounceKeyframes,
    cacheProgress,
    clearCache_,
    cacheLives
  } = app.ports;

  const { introMusic } = Audio.load();

  playIntroMusic.subscribe(() => {
    const musicPlaying = () => introMusicPlaying.send(true);
    Audio.playTrack(introMusic, musicPlaying);
  });

  fadeMusic.subscribe(() => {
    Audio.longFade(introMusic);
  });

  generateBounceKeyframes.subscribe(tileSize => {
    const styleNode = document.getElementById("generated-styles");
    styleNode.textContent = Bounce.generateKeyframes(tileSize);
  });

  cacheProgress.subscribe(progress => {
    Cache.setProgress(progress);
  });

  clearCache_.subscribe(() => {
    Cache.clear();
    window.location.reload();
  });

  cacheLives.subscribe(times => {
    Cache.setLives(times);
  });
}