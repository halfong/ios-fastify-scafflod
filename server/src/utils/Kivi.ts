export type KiviOpts = { date?: Date; uid?: string };

export interface KiviLike {
  add( key: string, value: any, opts?: KiviOpts ): Promise<void>;
  set( key: string, value: any, opts?: KiviOpts ): Promise<void>;

  find( key: string, opts?: KiviOpts ): Promise<any | null>;
  get( key: string, start: Date, end: Date, opts?: Pick<KiviOpts, 'uid'> ): Promise<any[]>;

  delete( key: string, opts?: Pick<KiviOpts, 'uid'> ): Promise<void>;
  deleteAll( key: string, opts?: Pick<KiviOpts, 'uid'> ): Promise<void>;
}

/** Minimal interface for any Prisma model delegate used by Kivi. */
export interface KiviModelDelegate {
  create(args: any): Promise<any>;
  update(args: any): Promise<any>;
  findFirst(args: any): Promise<any | null>;
  findMany(args: any): Promise<any[]>;
  delete(args: any): Promise<any>;
  deleteMany(args: any): Promise<any>;
}

/**
 * Key/Value storage utility built on a Prisma model delegate.
 * The caller chooses which table to target by passing the appropriate
 * delegate (e.g. $db.kiviReceipt, $db.kiviAudit) to the constructor.
 *
 * - key can be repeated; only the latest record (by created_at) is
 *   considered valid for find/set/delete.
 * - value is stored as JSON, allowing flexible data structures.
 * - opts.uid scopes all queries to a specific user (stored as a column,
 *   reducing the need to embed the user ID in the key string).
 * - opts.date supports time-bucketed audit records (one row per day).
 */
export default class Kivi implements KiviLike {

  private model: KiviModelDelegate;

  constructor( model: KiviModelDelegate ) {
    this.model = model;
  }

  private where( key: string, opts?: Partial<KiviOpts> ) {
    return {
      key,
      ...( opts?.uid  !== undefined ? { uid:  opts.uid  } : {} ),
      ...( opts?.date !== undefined ? { date: opts.date } : {} ),
    };
  }

  async add( key: string, value: any, opts?: KiviOpts ): Promise<void> {
    await this.model.create({
      data: { key, value, uid: opts?.uid, date: opts?.date }
    });
  }

  // Create or update (merge value) the latest record for key + uid scope.
  async set( key: string, value: any, opts?: KiviOpts ): Promise<void> {
    const existedRecord = await this.model.findFirst({
      where: this.where( key, opts ),
      orderBy: { created_at: 'desc' }
    });
    if ( existedRecord ) {
      await this.model.update({
        where: { id: existedRecord.id },
        data: { value: { ...existedRecord.value as any, ...value }, date: opts?.date ?? existedRecord.date }
      });
    } else {
      await this.add( key, value, opts );
    }
  }

  // Get the latest record for key (+ optional uid/date), returning its value.
  async find( key: string, opts?: KiviOpts ): Promise<any | null> {
    return ( await this.model.findFirst({ where: this.where( key, opts ), orderBy: { created_at: 'desc' } }) )?.value ?? null;
  }

  async get( key: string, start: Date, end: Date, opts?: Pick<KiviOpts, 'uid'> ): Promise<any[]> {
    const records = await this.model.findMany({
      where: {
        key,
        ...( opts?.uid !== undefined ? { uid: opts.uid } : {} ),
        date: { gte: start, lte: end }
      },
      orderBy: { created_at: 'desc' }
    });
    return records.map( (record: any) => record.value );
  }

  async delete( key: string, opts?: Pick<KiviOpts, 'uid'> ): Promise<void> {
    const record = await this.model.findFirst({ where: this.where( key, opts ), orderBy: { created_at: 'desc' } });
    if ( record ) {
      await this.model.delete({ where: { id: record.id } });
    }
  }

  async deleteAll( key: string, opts?: Pick<KiviOpts, 'uid'> ): Promise<void> {
    await this.model.deleteMany({ where: this.where( key, opts ) });
  }

}
