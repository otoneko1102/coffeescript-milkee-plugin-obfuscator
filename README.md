# milkee-plugin-obfuscator

This is a plugin for [milkee](https://www.npmjs.com/package/milkee) .

A Milkee plugin for obfuscation.

## Usage

### Setup

#### coffee.config.cjs

```js
const obfuscator = require('milkee-plugin-obfuscator');

module.exports = {
  // ...
  milkee: {
    plugins: [
      // Pass options to javascript-obfuscator (optional)
      obfuscator({
        compact: true,
        controlFlowFlattening: true,
        // ...see https://github.com/javascript-obfuscator/javascript-obfuscator#options
      }),
      // ...
    ]
  }
}
```

### Run

```sh
milkee
# or
npx milkee
```

### Options

You can pass any [javascript-obfuscator options](https://github.com/javascript-obfuscator/javascript-obfuscator#options) to the plugin:

```js
obfuscator({
  compact: false,
  stringArray: true,
  // ...
})
```

Or set `milkee.obfuscatorOptions` in your config for global options.

---

All compiled `.js` files will be obfuscated after build.
