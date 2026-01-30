
fs = require 'fs'
path = require 'path'
consola = require 'consola'
obfuscator = require 'javascript-obfuscator'

pkg = require '../package.json'
PREFIX = "[#{pkg.name}]"

# Create a custom logger with prefix
c = {}
for method in ['log', 'info', 'success', 'warn', 'error', 'debug', 'start', 'box']
  do (method) ->
    c[method] = (args...) ->
      if typeof args[0] is 'string'
        args[0] = "#{PREFIX} #{args[0]}"
      consola[method] args...

# Main plugin function
main = (compilationResult, opts = {}) ->
  { config, compiledFiles, stdout, stderr } = compilationResult

  configOpts = (config?.milkee?.obfuscatorOptions) or {}
  merged = Object.assign {}, configOpts, opts

  c.info "Obfuscates #{compiledFiles.length} file(s)"

  try
    for file in compiledFiles
      continue unless file?.endsWith('.js')

      if Array.isArray(merged.exclude) and merged.exclude.some (p) -> file.indexOf(p) isnt -1 or path.basename(file) is p
        c.info "Skipped (excluded): #{file}"
        continue

      optsForFile = Object.assign {}, merged
      optsForFile.inputFileName ?= path.basename(file)

      if optsForFile.vmObfuscation
        c.error "vmObfuscation requires JavaScript Obfuscator Pro (use obfuscatePro with an API token)."
        throw new Error 'vmObfuscation requires JavaScript Obfuscator Pro (obfuscatePro)'

      code = fs.readFileSync(file, 'utf8')
      result = obfuscator.obfuscate(code, optsForFile)
      obfuscated = result.getObfuscatedCode()

      if optsForFile.sourceMap and optsForFile.sourceMapMode isnt 'inline'
        map = result.getSourceMap()
        if map and map.length > 0
          mapName = if optsForFile.sourceMapFileName then optsForFile.sourceMapFileName else path.basename(file) + '.map'
          mapPath = path.join(path.dirname(file), mapName)
          fs.writeFileSync(mapPath, map, 'utf8')

          url = if optsForFile.sourceMapBaseUrl then optsForFile.sourceMapBaseUrl.replace(/\/$/, '') + '/' + mapName else mapName
          obfuscated += "\n//# sourceMappingURL=#{url}"

      fs.writeFileSync(file, obfuscated, 'utf8')
      c.success "Obfuscated: #{file}"
  catch error
    c.error "Obfuscation failed: #{error.message}"
    throw error

module.exports = (userOptions = {}) ->
  (compilationResult) ->
    mergedOpts = Object.assign {}, (compilationResult?.config?.milkee?.obfuscatorOptions) or {}, userOptions
    main compilationResult, mergedOpts
