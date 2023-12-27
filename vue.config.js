module.exports = {
  publicPath: process.env.VUE_BASE_PATH || '/',
  assetsDir: 'assets',

  devServer: {
    proxy: {
      '/api/v1': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        logLevel: 'debug',
        ws: true
      },
      '/version': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        logLevel: 'debug',
        ws: true
      },
      '/features': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        logLevel: 'debug',
        ws: true
      }
    }
  },

  chainWebpack: (config) => {
    config.resolve.alias.set('vue', '@vue/compat')

    config.module
      .rule('vue')
      .use('vue-loader')
      .tap((options) => {
        return {
          ...options,
          compilerOptions: {
            compatConfig: {
              MODE: 2
            }
          }
        }
      })
  }
}
