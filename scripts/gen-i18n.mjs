import fs from 'node:fs'
import path from 'node:path'

const projectRoot = process.cwd()

const sourceFile = path.join(projectRoot, 'i18n', 'messages.json')

const outputs = [
  {
    target: 'appscope',
    root: path.join(projectRoot, 'AppScope', 'resources')
  },
  {
    target: 'entry',
    root: path.join(projectRoot, 'entry', 'src', 'main', 'resources')
  }
]

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf-8'))
}

function writeJson(file, data) {
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, JSON.stringify(data, null, 2) + '\n', 'utf-8')
}

function normalizeTargets(config) {
  if (Array.isArray(config.targets)) {
    return config.targets
  }

  if (Array.isArray(config.scope)) {
    return config.scope
  }

  return ['entry']
}

function getValue(config, locale) {
  return config[locale] ?? config.base ?? ''
}

function generate() {
  const source = readJson(sourceFile)
  const locales = source.locales
  const strings = source.strings

  for (const output of outputs) {
    for (const locale of locales) {
      const result = {
        string: []
      }

      for (const [name, config] of Object.entries(strings)) {
        const targets = normalizeTargets(config)

        if (!targets.includes(output.target)) {
          continue
        }

        result.string.push({
          name,
          value: getValue(config, locale)
        })
      }

      const outputFile = path.join(output.root, locale, 'element', 'string.json')
      writeJson(outputFile, result)

      console.log(`Generated: ${outputFile}, count=${result.string.length}`)
    }
  }
}

generate()