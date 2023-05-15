/** @type {import('next').NextConfig} */
// const nextConfig = {
//   reactStrictMode: true,
// }

// module.exports = nextConfig

module.exports = {
		webpack(config) {
			config.module.rules.push(
				{
					test: /\.(glsl|vs|fs|vert|frag)$/,
					exclude: /node_modules/,
					use: [
						'raw-loader',
						'glslify-loader',
					]
				},
				{
					test: /\.ttf$/,
					use: 
					[
						{
							loader: 'ttf-loader',
							options: {
							name: './font/[hash].[ext]',
							},
						},
						'file-loader'
					]
				}
		);
		return config
	}
}