
export function Ms2MmSs(ms:number):string{
  if(ms<0)
    return '--:--';
  const totalSeconds: number = Math.floor(ms / 1000)
  const minutes: number = Math.floor(totalSeconds / 60)
  const seconds: number = totalSeconds % 60
  const mm: string = minutes.toString().padStart(2, '0')
  const ss: string = seconds.toString().padStart(2, '0')
  return `${mm}:${ss}`
}