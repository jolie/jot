/// Mimicking spring framework's JpaRepository interface

type ID: string

interface JpaRepository{
RequestResponse:
    findAll(undefined)(undefined),
    findAllById(ID)(undefined),
    saveAll(undefined)(undefined),
    flush(void)(void),
    saveAndFlush(undefined)(undefined),
    saveAllAndFlush(undefined)(undefined),
    deleteAllInBatch(void)(void),
    deleteAllByIdInBatch(ID)(void),
    getById(ID)(undefined)
}