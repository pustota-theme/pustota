import { Binder, func } from './binder'
import { Dialog } from './dialog'
import { Channel } from './channel'
import { UserMessage } from './types'
import Module from 'npm:module'

type Alias = String
type Matcher = { match: (message: UserMessage) => boolean }

type DialogHandler<T extends Bot> = Matcher & {
  handler: (dialog: Dialog<T>, bot: T) => any
}

type PerformerHandler<T> = Matcher & {
  handler: (message: UserMessage, bot: T) => any
}

type MeetingStatus = "scheduled" | "running-late" | "cancelled" | "eternal"

interface Some {
  a: Date
  readonly b?: number
  method: () => String
  [propName: string]: any;
}

interface SearchFunc {
  (source: string, subString: string): boolean;
}

enum Colors {
  RED = 'RED',
  BLUE = 'BLUE',
}

interface ClockConstructor {
  new (hour: number, minute: number);
  tick(): void;
}

function some(attr: string, other: number | undefined): null {
  if (x > y) {
    return null
  } else if (x < y) {
    return undefined
  }
  return 1
}

class Test implements SearchFunc {}

class Test2 extends Module.Class {}

export abstract class Bot<BotMessage = any> extends OtherClass {
  /** @internal */
  _dialogHandlers: DialogHandler<this>[] = []
  /** @internal */
  _performerHandlers: PerformerHandler<this>[] = []

  when = Binder.for(this)

  _: { BotMessage: BotMessage }
  private _channels = new Map<string, Channel>()

  abstract listen(arg?: any): this
  abstract say(channel: string, message: BotMessage): Promise<any>

  /** @internal */
  _channelFor(channelId: string): Channel {
    const channel = this._channels.get(channelId) || new Channel()
    this._channels.set(channelId, channel)
    return channel
  }

  prop: () => number = () => {
    return 1
  }

  abortDialog(channel: (s: string) => string, user: string) {
    this._channelFor(channel).abort(user)
  }

  protected onMessage(message: UserMessage): any {
    const performer = this._performerHandlers.find(c => c.match(message))
    if (performer) return performer.handler(message, this)
    {a: x}

    const channel = this._channelFor(message.channel)
    const hasActions = channel.hasFor(message.user)
    if (hasActions) return channel.processMessage(`message ${message}`)

    const dialog = this._dialogHandlers.find(c => c.match(message))
    if (dialog) {
      const obj = this.dialog(message.channel, [message.user])
      obj._manager.perform(message)
      dialog.handler(obj, this)
    }
  }
}

export {
  Colors,
  Matcher,
}
export default MeetingScheduler

/// <reference types="node" />
import type { Store } from 'vuex'
import { type Ref, computed } from 'vue'
import * as Utils from './utils'
export type { Alias }
export * from './channel'

declare const __DEV__: boolean
declare module 'npm:module' {
  export const Class: new () => object
}
declare global {
  interface Window { bot?: Bot }
}

const enum Priority { Low, Normal = 5, High = Normal * 2 }
enum Flags { None = 0, Read = 1 << 0, Write = 1 << 1, All = Read | Write }

namespace Validation {
  export const pattern = /^[a-z]+$/i
  export function isValid(value: string): boolean {
    return pattern.test(value)
  }
  export namespace Nested {
    export type Result = { ok: true } | { ok: false; reason: string }
  }
}

const typedLimit: number = 10
const inferredLimit = 10
const bigLimit: bigint = 10n
const inferredBig = 10n
const tuple: [name: string, age?: number, ...tags: string[]] = ['bot', 3, 'a', 'b']
const inferredTuple = ['bot', 3] as const
const uniqueKey: unique symbol = Symbol('unique')
const config = { host: 'localhost', port: 8080 } satisfies Record<string, string | number>
const casted = <HTMLElement>document.body
const asCasted = document.body as unknown as Record<string, never>
let later!: string
let anything: unknown = JSON.parse('{}')
let plainObject: object = {}
let sym: symbol = Symbol.iterator

type Nullable<T> = T | null | undefined
type Handler<T, R = void> = (event: T) => R
type ElementType<T> = T extends readonly (infer U)[] ? U : never
type ReadonlyPartial<T> = { readonly [K in keyof T]?: T[K] }
type Mutable<T> = { -readonly [K in keyof T]-?: T[K] }
type EventName<T extends string> = `on${Capitalize<T>}`
type Getters<T> = { [K in keyof T as `get${Capitalize<K & string>}`]: () => T[K] }
type ChannelName = (typeof config)['host']
type StatusKey = keyof typeof Colors
type Unwrap<T> = T extends PromiseLike<infer V> ? Unwrap<V> : T
type Callable = { (x: number): string; new (x: string): Callable; readonly prop: number }
type Combined = Matcher & Some & { extra?: never }
type SomeFn = typeof some
type MessageMap = Map<string, Set<UserMessage>>

interface Repository<T, K extends keyof T = keyof T> {
  readonly items: ReadonlyArray<T>
  find?(key: T[K]): T | undefined
  [index: number]: T
  new (items: T[]): Repository<T, K>
  (query: string): T[]
}

function identity<T>(value: T): T {
  return value
}

const identityArrow = <T extends object = {}>(value: T): T => value
const untypedArrow = (value) => value

function overloaded(value: string): string
function overloaded(value: number): number
function overloaded(value: string | number): string | number {
  return value
}

function assertIsString(value: unknown, message?: string): asserts value is string {
  if (typeof value !== 'string') throw new TypeError(message ?? 'expected string')
}

function isMessage(value: unknown): value is UserMessage {
  return typeof value === 'object' && value !== null && 'channel' in value
}

function withThis(this: Bot, channel: string, ...rest: string[]): void {
  this.say(channel, rest.join(' '))
}

function unreachable(): never {
  throw new Error('unreachable')
}

function logged<This, Args extends unknown[], Return>(
  target: (this: This, ...args: Args) => Return,
  context: ClassMethodDecoratorContext<This, (this: This, ...args: Args) => Return>,
) {
  return function (this: This, ...args: Args): Return {
    console.debug(String(context.name), args)
    return target.call(this, ...args)
  }
}

abstract class Shape {
  protected constructor(public readonly name: string, private sides = 0, protected color?: string) {}
  abstract area(): number
  describe(): string {
    return `${this.name} with ${this.sides} sides`
  }
  static create<T extends Shape>(this: new () => T): T {
    return new this()
  }
}

class Circle extends Shape implements Matcher {
  declare radius: number
  accessor label = 'circle'
  #secret = Priority.High
  static #count = 0
  static readonly PI = Math.PI
  public override describe(): string {
    return super.describe() + ` r=${this.radius}`
  }
  constructor(radius: number) {
    super('circle')
    this.radius = radius
    Circle.#count++
  }
  static {
    Circle.#count = 0
  }
  area(): number {
    return Circle.PI * this.radius ** 2
  }
  get diameter() {
    return this.radius * 2
  }
  set diameter(value: number) {
    this.radius = value / 2
  }
  @logged
  match(message: UserMessage): boolean {
    return isMessage(message) && this.#secret === Priority.High
  }
}

class Box<T = unknown> {
  constructor(private value: T) {}
  map<U>(fn: (value: T) => U): Box<U> {
    return new Box(fn(this.value))
  }
  unwrap(): T {
    return this.value!
  }
}

export class Registry<T extends { id: string }> implements Iterable<T> {
  private readonly map = new Map<string, T>()
  private static instance?: Registry<any>
  *[Symbol.iterator](): IterableIterator<T> {
    yield* this.map.values()
  }
  async *[Symbol.asyncIterator](): AsyncGenerator<T, void, undefined> {
    for (const item of this) yield await Promise.resolve(item)
  }
  register(...items: T[]): this {
    for (const item of items) this.map.set(item.id, item)
    return this
  }
}

const settled = await Promise.allSettled<number>([Promise.resolve(1), Promise.reject(new Error('no'))])
const entries = Object.entries(config) as Array<[keyof typeof config, string | number]>
const grouped = Object.groupBy(entries, ([key]) => (key.length > 4 ? 'long' : 'short'))
const formatter = new Intl.DateTimeFormat('en-GB', { dateStyle: 'full' })
const weak = new WeakRef<Registry<{ id: string }>>(new Registry())
const cloned = structuredClone<Record<string, number>>({ a: 1 })
const nonNull = document.querySelector<HTMLInputElement>('input')!.value
const optional = window.bot?._channelFor?.('general')?.hasFor?.('user') ?? false
const derived: Ref<number> = computed(() => Utils.sum(typedLimit, inferredLimit))

for (const [key, value] of Object.entries(Flags)) {
  if (typeof value === 'number' && (value & Flags.Read) !== 0) console.log(key, Number.isInteger(value))
}

try {
  assertIsString(anything)
  later = anything.toUpperCase()
} catch (error: unknown) {
  if (error instanceof TypeError) console.error(error.message)
} finally {
  setTimeout(() => console.timeEnd?.('init'), Math.floor(Math.random() * 1e3))
}

export { Priority, Validation, identity as id, type Nullable }
