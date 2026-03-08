module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'module-resolver',
        {
          root: ['.'],
          alias: {
            '@screens': './src/screens',
            '@components': './src/components',
            '@services': './src/services',
            '@stores': './src/stores',
            '@utils': './src/utils',
            '@theme': './src/theme',
            '@database': './src/database',
            '@hooks': './src/hooks',
            '@app': './src/app',
          },
        },
      ],
      'react-native-reanimated/plugin',
    ],
  };
};
