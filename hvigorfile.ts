import { appTasks } from '@ohos/hvigor-ohos-plugin'
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'

function findProjectRoot(startDir: string): string {
  let currentDir: string = startDir

  while (true) {
    const i18nFile: string = path.join(currentDir, 'i18n', 'messages.json')
    const scriptFile: string = path.join(currentDir, 'scripts', 'gen-i18n.mjs')
    const appScopeDir: string = path.join(currentDir, 'AppScope')
    const entryDir: string = path.join(currentDir, 'entry')

    if (
      fs.existsSync(i18nFile) &&
      fs.existsSync(scriptFile) &&
      fs.existsSync(appScopeDir) &&
      fs.existsSync(entryDir)
    ) {
      return currentDir
    }

    const parentDir: string = path.dirname(currentDir)

    if (parentDir === currentDir) {
      throw new Error('Cannot find project root.')
    }

    currentDir = parentDir
  }
}

function runI18nGenerator(): void {
  const projectRoot: string = findProjectRoot(process.cwd())
  const scriptFile: string = path.join(projectRoot, 'scripts', 'gen-i18n.mjs')
  const markerFile: string = path.join(projectRoot, '.i18n-gen.log')

  process.stderr.write(`[i18n] hvigorfile loaded. cwd=${process.cwd()}\n`)
  process.stderr.write(`[i18n] projectRoot=${projectRoot}\n`)
  process.stderr.write(`[i18n] script=${scriptFile}\n`)

  execFileSync(
    process.execPath,
    [scriptFile],
    {
      cwd: projectRoot,
      stdio: 'inherit'
    }
  )

  fs.appendFileSync(
    markerFile,
    `[i18n] generated at ${new Date().toISOString()}\n`,
    'utf-8'
  )

  process.stderr.write('[i18n] Done.\n')
}

runI18nGenerator()

export default {
  system: appTasks,
  plugins: []
}