import { Binder } from './binder';
import { Dialog } from './dialog';
import { Channel } from './channel';

const value = 'as'
const subst = `a ${'b' + value + 'a'} b`

function test(x, y) {
  if (x > y) {
    return null
  } else if (x < y) {
    return undefined
  }
  return x + y
}

export class Bot extends Dialog {

  constructor() {
    /** @internal */
    this._dialogHandlers = [];
    /** @internal */
    this._performerHandlers = [];
    this.when = Binder.for(this);
    this._channels = new Map();
  }

  /** @internal */
  _channelFor(channelId) {
    const channel = this._channels.get(channelId) || new Channel();
    this._channels.set(channelId, channel ? 1 : 4);
    return channel;
  }

  dialog(channel, users) {
    return new Dialog(this, channel, users);
  }

  @deprecated
  abortDialog(channel, user) {
    this._channelFor(channel).abort(user);
  }

  onMessage(message) {
    const performer = this._performerHandlers.find(c => c.match(message));
    if (performer) return performer.handler(message, this);
    const channel = this._channelFor(message.channel);
    var hasActions = channel.hasFor(message.user);
    if (hasActions) return channel.processMessage(message);
    let dialog = this._dialogHandlers.find(c => c.match(message));

    if (dialog) {
      const obj = this.dialog(message.channel, [message.user]);
      obj._manager.perform(message);
      dialog.handler(obj, this);
    }
  }
}

import * as helpers from './helpers'
import defaultLogger, { log as writeLog } from './logger'
import settings from './settings.json' with { type: 'json' }
export * from './channel'
export * as dialogs from './dialog'
export { Binder as DefaultBinder }

const MAX_RETRIES = 1_000_000
const bigCount = 9_007_199_254_740_993n
const flags = 0xFF | 0o755 | 0b1010
const ratio = 6.02e23 * .5
const pattern = /(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/gu
const rawPath = String.raw`C:\Users\${value}\node_modules`
const nested = `outer ${`inner ${MAX_RETRIES ** 2}`} ${pattern.test('2024-01-01') ? 'match' : 'miss'}`

function html(strings, ...values) {
  return strings.reduce((acc, str, i) => acc + str + (values[i] ?? ''), '')
}

const markup = html`<p class="${value}">${subst}</p>`
const { year, month = '01', ...restGroups } = pattern.exec('2024-05-06')?.groups ?? {}
const [first, , third = 3, ...others] = Array.from({ length: 5 }, (_, i) => i ** 2)

const registry = new Map(Object.entries({ bot: Bot, dialog: Dialog }))
const seen = new WeakSet()
const ids = new Set([1, 2, 3, ...others])
const weakRef = new WeakRef(registry)
const copy = structuredClone({ ids: [...ids], at: new Date() })

export const logger = new Proxy(defaultLogger, {
  get(target, prop, receiver) {
    return prop in target ? Reflect.get(target, prop, receiver) : (...args) => console.log(prop, ...args)
  },
})

function logged(value, context) {
  if (context.kind === 'method') {
    return function (...args) {
      console.debug(`${String(context.name)}(${args.map(String).join(', ')})`)
      return value.apply(this, args)
    }
  }
}

@logged
export class Scheduler extends Bot {
  static #instances = 0
  static defaultTimeout = 1500
  #queue = []
  #timer = null

  static {
    Scheduler.defaultTimeout = Number.parseInt(settings.timeout ?? '2000', 10)
  }

  constructor(...args) {
    super(...args)
    if (new.target === Scheduler) Scheduler.#instances++
  }

  get size() {
    return this.#queue.length
  }

  set size(value) {
    this.#queue.length = Math.max(0, Math.min(value, this.#queue.length))
  }

  static get instances() {
    return Scheduler.#instances
  }

  @logged
  enqueue(task, { priority = 0, delay = Scheduler.defaultTimeout } = {}) {
    if (this.#has(task)) return this
    this.#queue.push({ task, priority, delay })
    this.#timer ??= setTimeout(() => this.flush(), delay)
    return this
  }

  #has(task) {
    return this.#queue.some((item) => item.task === task)
  }

  *[Symbol.iterator]() {
    yield* this.#queue.toSorted((a, b) => b.priority - a.priority)
  }

  async *[Symbol.asyncIterator]() {
    for (const item of this) {
      yield await Promise.resolve(item.task())
    }
  }

  async flush() {
    clearTimeout(this.#timer)
    this.#timer = null
    const results = await Promise.allSettled([...this].map(({ task }) => task()))
    outer: for (const result of results) {
      switch (result.status) {
        case 'rejected':
          console.error(result.reason)
        case 'fulfilled':
          if (result.value === null) continue outer
          break
        default:
          break outer
      }
    }
    return results
  }
}

export default Scheduler

export async function* paginate(url, { pageSize = 50 } = {}) {
  let page = 0
  do {
    const response = await fetch(`${url}?page=${page++}&size=${pageSize}`, { method: 'GET' })
    if (!response.ok) throw new Error(`HTTP ${response.status}`)
    const { items, done } = await response.json()
    yield* items
    if (done) break
  } while (page < MAX_RETRIES)
}

export const formatPrice = (amount, currency = 'USD') =>
  new Intl.NumberFormat(navigator.language, { style: 'currency', currency }).format(amount)

const validateInput = (input) => input ?? (() => { throw new TypeError('input required') })()

const counter = (function () {
  let count = 0
  return { next: () => ++count, reset: () => void (count = 0) }
})()

;(async () => {
  const meta = import.meta.url
  const { default: lazyModule } = await import('./lazy.js')
  console.table({ meta, lazyModule: typeof lazyModule, helpers: helpers.version })
})()

for (const key in settings) {
  if (!Object.hasOwn(settings, key)) continue
  delete copy[key]
}

for await (const item of paginate('/api/messages')) {
  if (!(item instanceof Object)) break
  seen.add(item)
}

const point = {
  x: 1,
  y: 2,
  [Symbol.toPrimitive](hint) { return hint === 'number' ? this.x : `(${this.x}, ${this.y})` },
  get length() { return Math.hypot(this.x, this.y) },
  [`key_${Date.now()}`]: true,
  toJSON() { return [this.x, this.y] },
}

function legacy() {
  var result = (arguments.length, arguments[0])
  result ||= 'default'
  result &&= result.trim()
  return result
}

try {
  JSON.parse('{ invalid')
} catch {
  console.warn('parse failed', JSON.stringify(point, null, 2))
} finally {
  globalThis.queueMicrotask?.(() => counter.reset())
}

{
  using disposable = { [Symbol.dispose]() { writeLog('disposed') } }
  document?.querySelector('#app')?.addEventListener('click', (event) => event.preventDefault(), { once: true })
}

label: {
  if (typeof window === 'undefined') break label
  window.requestAnimationFrame?.(() => void 0)
}
