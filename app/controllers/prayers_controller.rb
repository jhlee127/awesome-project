class PrayersController < ApplicationController
  def index
    @korean_prayers = Prayer.select('id', 'prayer', 'name', 'relationship', 'note').order(:prayer)
    @english_prayers = Prayer.select('id', 'english_prayer', 'english_name', 'english_relationship', 'english_note').order(:english_prayer)
  end

  def new
    @prayer = Prayer.new
  end

  def edit
    @prayer = Prayer.find(params[:id])
  end

  def create
    @prayer = Prayer.new(prayer_params)

    #Save member --start
    english_prayer = @prayer.english_prayer
    korean_prayer = @prayer.prayer

    m = Member.find_by kor_name: korean_prayer

    if(m.nil?)
      @member = Member.new(eng_name: english_prayer, kor_name: korean_prayer)
      @member.save!
    end
    #Save member --end

    #Save Prayee --start
    english_name = @prayer.english_name
    korean_name = @prayer.name

    p = Prayee.find_by kor_name: korean_name

    if(p.nil?)
      @prayee = Prayee.new(eng_name:english_name, kor_name:korean_name)
      @prayee.save!
    end

    #End Prayee --end

    if @prayer.save!
      redirect_to prayers_path
    else
      render 'new'
    end
  end

  def show
    @prayer = Prayer.find(params[:id])
  end

  def destroy
    @prayer = Prayer.find(params[:id])
    @prayer.destroy

    redirect_to prayers_path
  end

  def update
    @prayer = Prayer.find(params[:id])
    if @prayer.update(prayer_params)
      flash[:notice] = "success"
      redirect_to prayer_path(@prayer)
    else
      render 'edit'
    end
  end

  def get_english_name
    kor_name = params[:kn]

    ep = Member.where(kor_name: kor_name).select("eng_name").first

    if(ep.nil?)
      render json: '' and return
    end

    render json: ep.eng_name and return
  end

  def get_prayee_english_name
    kor_name = params[:kn]

    ep = Prayee.where(kor_name: kor_name).select("eng_name").first

    if(ep.nil?)
      render json:'' and return
    end

    render json: ep.eng_name and return
  end

  private
  def prayer_params
    params.require(:prayer).permit(:prayer, :name, :relationship, :note, :english_prayer, :english_name, :english_relationship, :english_note)
  end

  def english_prayer_params
    params.require(:prayer).permit(:englishName, :englishRecipient, :englishRelation, :englishRemark)
  end
end
